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
     bucket                      = "my-ceph-bucket"       # Bucket name to store the tf state files.
     key                         = "fabric.tfstate"
     region                      = "some region"                    
     endpoint                    = "http://ceph-cluster-url:port"  # Your Ceph S3 endpoint.
     access_key                  = "your-ceph-access-key"
     secret_key                  = "your-ceph-secret-key"
    ...
   }
   ```

---

## Node Setup

To ensure that the pods are scheduled on specific nodes, you can apply labels to your nodes, taint the nodes, and configure the corresponding variable in your Terraform setup.

### 1. Labeling the Node
   - Use `kubectl` to label the node you want to use for scheduling pods. For example, if you want to label a DGX node with the label `type=sarvam`, run:

   ```bash
   kubectl label nodes <dgx-node-name> type=sarvam
   ```

   Replace `<dgx-node-name>` with the name of the node that you want to label.

### 2. Tainting the Node
   - To taint the node and prevent any pods from being scheduled unless they tolerate the taint, run the following command:

   ```bash
   kubectl taint nodes <dgx-node-name> sku=gpu:NoSchedule
   ```

   This command adds a taint with the key `sku`, value `gpu`, and effect `NoSchedule` to the specified node.


### 3. Node Selector in Terraform

   - Update the `fabric/variables.tf` file to include the node selector labels. The default label `type=sarvam` will be used to schedule the pods on the labeled nodes, You can ignore if node labeled as sarvam, or change the variable value in models and fabric to the one set for the DGX node.

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

- Update the `fabric/variables.tf` file with the Redis details:


```hcl
variable "kb_postgres_host" {
  type    = string
  default = "kb-postgres-service"  # Host url of postgres
}

variable "kb_postgres_port" {
  type    = string
  default = "5432"  # Port to connect with postgres db
}

variable "kb_postgres_user" {
  type    = string
  default = "postgres"   # Username for postgres user 
}

variable "kb_postgres_password" {
  sensitive = true
  default   = "password"  # Passowrd for postgres user 
}

variable "auth_postgres_host" {
  type    = string
  default = "auth-postgres-service"  # Host url of postgres
}

variable "auth_postgres_port" {
  type    = string
  default = "5432"  # Port to connect with postgres db
}

variable "auth_postgres_user" {
  type    = string
  default = "postgres"   # Username for postgres user 
}

variable "auth_postgres_password" {
  sensitive = true
  default   = "password"  # Passowrd for postgres user 
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
  default = "true"   # true if ssl enabled
}

variable "redis_url_prefix" {
  type    = string
  default = "rediss://:password@redis-service:6379" # Your redis url with password
}

variable "redis_password" {
  sensitive = true
  default   = "password" # rediss password
}

```

### 3. Ceph Setup
- Create two buckets in the ceph cluster, `apps` and `knowledge-base`

update the `fabric/variables.tf`, and replace the <ceph-storgae-url> in following variables.


```
variable "kb_storage_path" {
  type = string
  default = "https://<ceph-storgae-url>/knowledge-base"
}
```

```
# Bucket name shoud be `apps`
variable "app_storge_path" {
  type = string
  default = "https://<ceph-storgae-url>/app-storage/apps"
}
```
---

## Installation Steps

1. **Unzip the Providers**
  This is present inside terraform folder
  ```
  tar xvzf providers.tar.gz
  ```

2. **Configure Terraform to Use Unzipped Providers:**
  Create or update the ~/.terraformrc file to point to the unzipped providers:
  ```hcl
  provider_installation {
    filesystem_mirror {
      path    = "path to unzipped providers"
    }
  }
  ```
3. **Change directory to the `fabric/` folder:**

   ```bash
   cd fabric/
   ```

4. **Initialize Terraform:**

   ```bash
   terraform init
   ```

5. **Apply the Terraform configuration:**

   ```bash
   terraform apply
   ```

6. **Confirm the changes by typing `yes` when prompted.**

7. **Do the same steps to host models on cluster**

    NOTE: Do the same steps from 3-6 for `models` directory to host all the models.

    ```
    cd models/
    terraform init
    terraform apply
    ```