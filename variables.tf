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
  default     = "enreach$.com"
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