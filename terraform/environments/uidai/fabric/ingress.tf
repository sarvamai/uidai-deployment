resource "kubernetes_ingress_v1" "hello_world_ingress" {
  metadata {
    name      = "hello-world-ingress"
    namespace = "default"  # Update this if the ingress should be in a different namespace

    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"  = "false"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path     = "/auth"
          path_type = "Prefix"

          backend {
            service {
              name = "client-auth"
              port {
                number = 80
              }
            }
          }
        }

        path {
          path     = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "sarvam-authoring-ui"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}


resource "kubernetes_ingress_v1" "hello_world_ingress_1" {
  metadata {
    name      = "hello-world-ingress-2"
    namespace = "default"  # Update this if the ingress should be in a different namespace

    annotations = {
      "nginx.ingress.kubernetes.io/ssl-redirect"  = "false"
      "nginx.ingress.kubernetes.io/use-regex"      = "true"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/$1"  # Capture everything after the prefix
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        path {
          path     = "/api/app-runtime/(.*)"  # Match everything after /api/api-runtime/
          path_type = "Prefix"

          backend {
            service {
              name = "sarvam-app-runtime-service"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}