resource "kubernetes_persistent_volume" "local_storage_pv" {
  metadata {
    name = "local-storage-pv"
  }
  spec {
    capacity = {
      storage = "100Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/mnt/disks/logs" # Path on the host node
      }
    }
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "manual"
  }
}

resource "kubernetes_persistent_volume_claim" "local_storage_pvc" {
  depends_on = [kubernetes_persistent_volume.kb_postgres_pv]
  metadata {
    name = "local-storage-pvc"
  }

  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "100Gi"
      }
    }

    volume_name = kubernetes_persistent_volume.local_storage_pv.metadata.0.name
  }
}
