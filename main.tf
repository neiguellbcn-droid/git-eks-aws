data "aws_availability_zones" "available" {}
# subconjunto de 2 zonas disponibles
locals {  
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

# 1. Red VPC optimizada sobre coste por solicitud de EKS.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true # Ahorro: 1 solo NAT Gateway
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# 2. Clúster Amazon EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  # Activa logs en CloudWatch
  create_cloudwatch_log_group = true
  cluster_enabled_log_types   = []

  cluster_addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { most_recent = true }
  }
# GESTION DE NODOS
  eks_managed_node_groups = {
    spot_arm = {
      ami_type       = var.eks_managed_node_groups["spot_arm"].ami_type
      instance_types = var.eks_managed_node_groups["spot_arm"].instance_types
      capacity_type  = var.eks_managed_node_groups["spot_arm"].capacity_type
      min_size       = var.eks_managed_node_groups["spot_arm"].min_size
      max_size       = var.eks_managed_node_groups["spot_arm"].max_size
      desired_size   = var.eks_managed_node_groups["spot_arm"].desired_size
    }
  }
}

# 3. Permisos IAM para el AWS Load Balancer Controller
module "lb_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${var.cluster_name}-alb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# 4. Instalación del AWS Load Balancer Controller vía Helm
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  replace    = true
  wait       = true

  values = [
    yamlencode({
      clusterName = module.eks.cluster_name
      region      = var.aws_region
      vpcId       = module.vpc.vpc_id
      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
           (format("%s.%s/%s", "eks", "amazonaws.com", "role-arn")) = module.lb_role.iam_role_arn
        }
      
      }
    })
  ]

  depends_on = [module.eks]
}

# 5. Namespace de aplicaciones
resource "kubernetes_namespace_v1" "apps" {
  metadata {
    name = var.app_namespace
  }

  depends_on = [module.eks]
}