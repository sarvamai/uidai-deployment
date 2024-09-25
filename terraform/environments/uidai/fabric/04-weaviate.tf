resource "helm_release" "weaviate" {

  name      = "kb-weaviate"
  namespace = "default"

  repository = "../helm-charts/weaviate/weaviate"
  chart      = "weaviate"

  # force_update  = true
  recreate_pods = true
  reset_values  = true

  values = [<<EOF
    replicas: 1
    EOF
  ]
}