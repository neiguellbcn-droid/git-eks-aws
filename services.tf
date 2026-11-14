# 1. Repositorio de Imágenes Docker (Amazon ECR)
resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.cluster_name}-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Permite que terraform destroy borre el repo aunque tenga imágenes

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 2. Grupo de Subredes Privadas y Firewall para MySQL (Puerto 3306)
resource "aws_db_subnet_group" "mysql_subnets" {
  name       = "${var.cluster_name}-mysql-subnets"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "mysql_sg" {
  name        = "${var.cluster_name}-mysql-sg"
  description = "Permite trafico MySQL solo desde los nodos de EKS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = var.db_forward_port
    to_port         = var.db_instance_port
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }
}

# 3. Instancia Gestionada de Amazon RDS (MySQL)
resource "aws_db_instance" "mysql" {
  identifier             = "${var.cluster_name}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t4g.micro" # Instancia económica ARM
  allocated_storage      = 20
  db_name                = "appdb"
  username               = "admin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.mysql_subnets.name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  skip_final_snapshot    = true # Evita bloqueos al ejecutar terraform destroy
  publicly_accessible    = false
}

#· 4. DNS con Route 53 

data "aws_route53_zone" "main" {
  name         = var.dns_zone
  private_zone = false
}

data "aws_lb" "eks_alb" {
  tags = {
    "elbv2.k8s.aws/cluster" = module.eks.cluster_name
  }
  depends_on = [kubernetes_ingress_v1.demo_app]
}

resource "aws_route53_record" "app_dns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "app.${data.aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = data.aws_lb.eks_alb.dns_name
    zone_id                = data.aws_lb.eks_alb.zone_id
    evaluate_target_health = true
  }
}

