resource "kubernetes_deployment" "demo_app" {
  metadata {
    name      = "web-demo"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
    labels    = { app = "web-demo" }
  }

  spec {
    replicas = 2

    selector {
      match_labels = { app = "web-demo" }
    }

    template {
      metadata {
        labels = { app = "web-demo" }
      }

      spec {
        container {
          name  = "podinfo"
          image = "ghcr.io/stefanprodan/podinfo:6.7.0"

          port {
            container_port = 9898
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "demo_app" {
  metadata {
    name      = "web-demo-svc"
    namespace = kubernetes_namespace_v1.apps.metadata[0].name
  }

  spec {
    selector = { app = "web-demo" }

    port {
      port        = 80
      target_port = 9898
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "demo_app" {
  metadata {
    name      = "web-demo-ingress"
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
              name = kubernetes_service.demo_app.metadata[0].name
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