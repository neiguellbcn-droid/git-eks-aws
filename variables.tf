variable "aws_region" {
  description = "Región de AWS donde se desplegará EKS"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "Nombre del bucket S3 para almacenar el estado de Terraform"
  type        = string
  default     = "tfstate-eks-300601069255"
}

variable key_s3 {
  description = "Ruta del archivo de estado de Terraform en S3"
  type        = string
  default     = "eks-prod/terraform.tfstate"
}

varable "dynamodb_table" {
  description = "Nombre de la tabla DynamoDB para el bloqueo del estado de Terraform"
  type        = string
  default     = "tfstate-eks-300601069255-lock"
}

variable "cluster_name" {
  description = "Nombre del clúster EKS"
  type        = string
  default     = "eks-aws-prod"
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes"
  type        = string
  default     = "1.31"
}

variable "app_namespace" {
  description = "Namespace para aplicaciones en Kubernetes"
  type        = string
  default     = "apps"
}

variable "dns_zone" {
  description = "Nombre de la zona DNS en Route 53"
  type        = string
  default     = "enreach$.com"
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "CIDR de las subredes privadas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "CIDR de las subredes públicas"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "eks_managed_node_groups" {
  description = "Configuración de los grupos de nodos gestionados por EKS"
  type = map(object({
    ami_type       = string
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
  })) 
  default = {
    spot_arm = {
      ami_type       = "AL2023_ARM_64_STANDARD"
      instance_types = ["t4g.medium", "t4g.small"]
      capacity_type  = "SPOT"
      min_size       = 1
      max_size       = 2
      desired_size   = 1
  
    }}
}
###############################################################################
###   RECUERDA QUE DEBE ESTAR EL SECRETO DE LA BASE DE DATOS EN GITHUB (Settings -> Secrets and variables -> Actions -> New repository secret)   ##
# y que debe ser llamado db_password, para que el workflow de GitHub Actions pueda desplegar la app en EKS y conectarse a la base de datos RDS MySQL
###############################################################################

variable "db_password" {
  description = "Contraseña maestra para la base de datos MySQL en RDS"
  type        = string
  sensitive   = true
}

variable "db_instance_port" {
  description = "Puerto de la instancia de base de datos MySQL en RDS"
  type        = number
  default     = 3306
}

variable "db_forward_port" {
  description = "Puerto de reenvío para la base de datos MySQL en RDS"
  type        = number
  default     = 3306
}