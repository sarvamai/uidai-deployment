resource "helm_release" "weaviate" {

  name      = "kb-weaviate"
  namespace = "default"

  # replce this with local helm charts path
  repository = "https://weaviate.github.io/weaviate-helm/"
  chart      = "weaviate"

  # force_update  = true
  recreate_pods = true
  reset_values  = true

  values = [<<EOF
    replicas: 1
    EOF
  ]
}