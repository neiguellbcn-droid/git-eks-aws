resource "kubernetes_deployment_v1" "spot_app" {
  metadata {
    name      = "spot-app"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "spot-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "spot-app"
        }
      }

      spec {
        container {
          name  = "wordpress"
          image = "wordpress:latest" # Compatible con nodos ARM64 Spot

          port {
            container_port = 80
          }

          # Conexión automática con la base de datos RDS MySQL
          env {
            name  = "WORDPRESS_DB_HOST"
            value = aws_db_instance.mysql.endpoint
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value = aws_db_instance.mysql.username
          }
          env {
            name  = "WORDPRESS_DB_PASSWORD"
            value = var.db_password
          }
          env {
            name  = "WORDPRESS_DB_NAME"
            value = aws_db_instance.mysql.db_name
          }
        }
      }
    }
  }

  depends_on = [aws_db_instance.mysql]
}

resource "kubernetes_service_v1" "spot_app" {
  metadata {
    name      = "spot-app-service"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  spec {
    selector = {
      app = "spot-app"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "spot_app" {
  metadata {
    name      = "spot-app-ingress"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
    annotations = {
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.spot_app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.aws_lb_controller]
}