Here’s the updated README with the section on node labeling and variable configuration:

---

# Terraform Setup and Configuration

## Prerequisites

### 1. Install `kubectl`
   - Ensure that `kubectl` is installed and configured with access to the cluster.
   - Verify that you have the correct `.kube/config` file and the correct cluster context.

### 2. Install `terraform`
   - Update the following Terraform configuration files:
     - **`fabric/providers.tf`** 
     - **`models/providers.tf`**

   - Modify the `config_path` and `config_context` fields to reflect the path to your `.kube/config` file and the name of your cluster context.

   ```hcl
   provider "kubernetes" {
     config_path    = "path/to/.kube/config"
     config_context = "cluster-context"
   }

   provider "helm" {
     kubernetes {
       config_path    = "path/to/.kube/config"
       config_context = "cluster-context"
     }
   }
   ```

### 3. Configure Terraform Backend (for Ceph)
   - Update the backend configuration to use Ceph-compatible S3 storage:

   ```hcl
   backend "s3" {
     bucket                      = "my-ceph-bucket"
     key                         = "fabric.tfstate"
     region                      = "us-east-1"                    # Ceph usually requires a region.
     endpoint                    = "http://ceph-cluster-url:port"  # Your Ceph S3 endpoint.
     access_key                  = "your-ceph-access-key"
     secret_key                  = "your-ceph-secret-key"
     skip_credentials_validation = true  # Required for Ceph compatibility.
     skip_region_validation      = true  # Required for Ceph compatibility.
   }
   ```

---

## Node Labeling Setup

To ensure that the pods are scheduled on specific nodes, you can apply labels to your nodes and configure the corresponding variable in your Terraform setup.

### 1. Labeling the Node
   - Use `kubectl` to label the node you want to use for scheduling pods. For example, if you want to label a DGX node with the label `type=sarvam`, run:

   ```bash
   kubectl label nodes <dgx-node-name> type=sarvam
   ```

   Replace `<dgx-node-name>` with the name of the node that you want to label.

### 2. Node Selector in Terraform

   - Update the `fabric/variables.tf` file to include the node selector labels. The default label `type=sarvam` will be used to schedule the pods on the labeled nodes:

   ```hcl
   variable "node_selector_labels" {
     type        = map(string)
     nullable    = false
     default     = {
       type = "sarvam"
     }
     description = "Labels for selecting nodes to schedule pods of the deployment"
   }
   ```

   This will ensure that the deployment pods are scheduled only on the nodes labeled `type=sarvam`.

---

## External Dependencies

### 1. PostgreSQL Databases

You need to set up two PostgreSQL databases:
  - `kb-db`
  - `auth-db`

For these databases, create Kubernetes secrets:

1. **Secret for `kb-db`:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kb-postgres-db-secrets
  namespace: <your-namespace>
data:
  DATABASE_PASSWORD: <base64-encoded-password-for-kb-db>
```

2. **Secret for `auth-db`:**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: auth-postgres-db-secrets
  namespace: <your-namespace>
data:
  DATABASE_PASSWORD: <base64-encoded-password-for-auth-db>
```

After creating the secrets, update the `fabric/variables.tf` file with PostgreSQL details:

```hcl
variable "kb_postgres_host" {
  type    = string
  default = "kb-postgres-service"
}

variable "kb_postgres_port" {
  type    = string
  default = "5432"
}

variable "kb_postgres_user" {
  type    = string
  default = "postgres"
}

variable "auth_postgres_host" {
  type    = string
  default = "auth-postgres-service"
}

variable "auth_postgres_port" {
  type    = string
  default = "5432"
}

variable "auth_postgres_user" {
  type    = string
  default = "postgres"
}
```

### 2. Redis Configuration

You need to configure Redis with environment variables and secrets.

- Update the `fabric/variables.tf` file with the Redis details:

```hcl
variable "redis_host" {
  type    = string
  default = "redis-service"
}

variable "redis_port" {
  type    = string
  default = "6379"
}

variable "redis_tls" {
  type    = string
  default = "false"
}
```

- Create a ConfigMap for Redis:

```hcl
module "redis_config_maps" {
  source = "../../../modules/config-maps"

  name       = "redis-env"
  namespaces = [var.fabric_namespace]
  data = {
    "REDIS_HOST" = var.redis_host
    "REDIS_PORT" = var.redis_port
    "REDIS_TLS"  = var.redis_tls
  }
}
```

- Create a secret `redis-secrets` with the Redis password and URL:

```hcl
module "redis_secrets" {
  source = "../../../modules/secrets"

  name       = "redis-secrets"
  namespaces = [var.fabric_namespace]
  data = {
    "REDIS_PASSWORD" = {
      "value" = "redis-password"
    }
    "REDIS_URL_PREFIX" = {
      "value" = "redis://:password@redis-service:6379"
    }
  }
}
```

### 3. Additional Secrets

You also need to create additional secrets for the authentication service:

1. **Shared Auth Secrets:**

```hcl
module "auth_shared_secrets" {
  source = "../../../modules/secrets"

  name       = "auth-shared-secrets"
  namespaces = [var.fabric_namespace]
  data = {
    "TOKEN_JWT_SECRET_ACCESS_KEY" = "your-secret-access-key"
  }
}
```

2. **Auth Service Secrets:**

You can generate the JWT secret keys using `openssl rand -base64 32`

```hcl
module "auth_service_secrets" {
  source = "../../../modules/secrets"

  name       = "auth-service-secrets"
  namespaces = [var.fabric_namespace]
  data = {
    "FIRST_USER_PASSWORD" = "admin-password"
    "TOKEN_JWT_SECRET_REFRESH_KEY" = "your-secret-refresh-key"
  }
}
```

3. **Create a Kubernetes Secret for Ceph Credentials**

- Create a Kubernetes secret named `ceph-secrets` for managing your access keys:

```yaml
apiVersion: v1
kind: Secret
metadata:
    name: ceph-secrets
    namespace: <your-namespace>
data:
    AWS_ACCESS_KEY_ID: <base64-encoded-ceph-access-key>
    AWS_SECRET_ACCESS_KEY: <base64-encoded-ceph-secret-key>
```

Replace `<base64-encoded-ceph-access-key>` and `<base64-encoded-ceph-secret-key>` with your Ceph access and secret keys, base64 encoded.

---

## Installation Steps

1. **Change directory to the `fabric/` folder:**

   ```bash
   cd fabric/
   ```

2. **Initialize Terraform:**

   ```bash
   terraform init
   ```

3. **Apply the Terraform configuration:**

   ```bash
   terraform apply
   ```

4. **Confirm the changes by typing `yes` when prompted.**

This will create the necessary infrastructure, including Kubernetes resources, ConfigMaps, Secrets, and more.