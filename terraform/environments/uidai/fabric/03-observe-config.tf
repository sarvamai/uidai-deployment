
module "observe_env" {
  source = "../../../modules/config-maps"

  name       = "observe-env"
  namespaces = ["default"]
  data = {
    OBSERVE_USE_GCP = "false"
  }
}
