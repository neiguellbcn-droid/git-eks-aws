output "configure_kubectl" {
  description = "Ejecuta este comando para conectar tu terminal al clúster EKS"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "get_alb_url" {
  description = "Comando para obtener la URL pública de tu aplicación en AWS"
  value       = "kubectl get ingress web-demo-ingress -n ${var.app_namespace} -o jsonpath='{.status.loadBalancer.ingress.hostname}'"
}
