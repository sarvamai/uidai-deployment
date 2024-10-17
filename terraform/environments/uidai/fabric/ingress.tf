resource "kubernetes_ingress_v1" "sarvam-authoring-ui-ingress" {
  metadata {
    name = "authoring-ui-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-methods" = "GET, PUT, POST, DELETE, PATCH, OPTIONS"
      "nginx.ingress.kubernetes.io/cors-allow-origin" = "*"
      "nginx.ingress.kubernetes.io/cors-allow-credentials" = "true"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "sarvam-authoring-ui"  # Reference the backend service
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

resource "kubernetes_ingress_v1" "client-auth-ingress" {
  metadata {
    name = "client-auth-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
      "nginx.ingress.kubernetes.io/enable-cors" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-methods" = "GET, PUT, POST, DELETE, PATCH, OPTIONS"
      "nginx.ingress.kubernetes.io/cors-allow-origin" = "*"
      "nginx.ingress.kubernetes.io/cors-allow-credentials" = "true"
    }
  }

  spec {
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "client-auth"  # Reference the backend service
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