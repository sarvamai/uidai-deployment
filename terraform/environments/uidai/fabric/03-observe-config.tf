
module "observe_env" {
  source = "../../../modules/config-maps"

  name       = "observe-env"
  namespaces = [var.fabric_namespace]
  data = {
    OBSERVE_USE_GCP = "false"
  }
}
