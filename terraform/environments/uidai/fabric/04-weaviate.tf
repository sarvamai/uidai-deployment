resource "helm_release" "weaviate" {

  name      = "kb-weaviate"
  namespace = var.fabric_namespace

  chart      = "../helm-charts/weaviate/weaviate"

  # force_update  = true
  recreate_pods = true
  reset_values  = true

  values = [<<EOF
    serviceAccountName: ${var.fabric_service_account}
    replicas: 1
    tolerations:
      - key: "sku"
        operator: "Equal"
        value: "gpu"
        effect: "NoSchedule"
    EOF
  ]
}