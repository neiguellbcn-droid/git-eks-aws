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
  default     = "mi-app"
}
