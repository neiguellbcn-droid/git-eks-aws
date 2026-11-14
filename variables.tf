variable "tfstate_bucket" {
  description = "Nombre del bucket de Terraform state"
  type        = string
  default     = "tfstate-eks-123456789012"
}

variable "aws_region" {
  description = "Región de AWS donde se desplegará EKS"
  type        = string
  default     = "eu-west-1"
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
  default     = "eldominio.com"
}

variable "vpc_cidr" {
  description = "CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Subredes privadas para la VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Subredes públicas para la VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable ami_type {
  description = "Tipo de AMI para los nodos del clúster EKS"
  type        = string
  default     = "AL2023_ARM_64_STANDARD"
}

variable "instance_types" {
  description = "Tipos de instancia para los nodos del clúster EKS"
  type        = list(string)
  default     = ["t4g.medium", "t4g.small"]
}

variable "capacity_type" {
  description = "Tipo de capacidad para los nodos del clúster EKS"
  type        = string
  default     = "SPOT"
}

variable "min_size" {
  description = "Tamaño mínimo del grupo de nodos"
  type        = number
  default     = 1
} 

variable "max_size" {
  description = "Tamaño máximo del grupo de nodos"
  type        = number
  default     = 2
} 

variable "desired_size" {
  description = "Tamaño deseado del grupo de nodos"
  type        = number    
  default     = 1
}

###############################################################################
###   RECUERDA QUE DEBE ESTAR EL SECRETO DE LA BASE DE DATOS DE LA ENTIDAD (Settings -> Secrets and variables -> Actions -> New repository secret)   ##
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