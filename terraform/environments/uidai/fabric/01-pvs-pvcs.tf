resource "kubernetes_persistent_volume" "kb_postgres_pv" {
  metadata {
    name = "kb-postgres-pv"
  }
  spec {
    capacity = {
      storage = "30Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/mnt/data/postgres/kb" # Path on the host node
      }
    }
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "manual"
  }
}

resource "kubernetes_persistent_volume_claim" "kb_postgres_pvc" {
  depends_on = [kubernetes_persistent_volume.kb_postgres_pv]
  metadata {
    name = "kb-postgres-pvc"
  }

  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "30Gi"
      }
    }

    volume_name = kubernetes_persistent_volume.kb_postgres_pv.metadata.0.name
  }
}


resource "kubernetes_persistent_volume" "auth_postgres_pv" {
  metadata {
    name = "auth-postgres-pv"
  }
  spec {
    capacity = {
      storage = "30Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      host_path {
        path = "/mnt/data/postgres/auth" # Path on the host node
      }
    }
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "manual"
  }
}

resource "kubernetes_persistent_volume_claim" "auth_postgres_pvc" {
  depends_on = [kubernetes_persistent_volume.auth_postgres_pv]

  metadata {
    name = "auth-postgres-pvc"
  }

  spec {
    storage_class_name = "manual"
    access_modes       = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "30Gi"
      }
    }

    volume_name = kubernetes_persistent_volume.auth_postgres_pv.metadata.0.name
  }
}
