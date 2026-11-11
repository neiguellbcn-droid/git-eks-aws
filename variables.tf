variable "aws_region" {
  description = "Región de AWS donde se desplegará EKS"
  type        = string
  default     = "eu-west-1"
}

variable "cluster_name" {
  description = "Nombre del clúster EKS"
  type        = string
  default     = "lab-eks-prod"
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes (usa una reciente para evitar recargos de soporte extendido)"
  type        = string
  default     = "1.31"
}

variable "app_namespace" {
  description = "Namespace para tus aplicaciones"
  type        = string
  default     = "mi-app"
}
