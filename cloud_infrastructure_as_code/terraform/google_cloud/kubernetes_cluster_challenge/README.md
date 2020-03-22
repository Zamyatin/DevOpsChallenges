# Let's build a Google Kubenetes Engine (GKE) Cluster!
The goal of this excercise is to build a simple Kubernetes cluster by writing some Terraform Code. 

## What you need
To get you underway, you will be provisioned a few things:
1. A Google Project, which will have some budget constraints (so we can keep costs reasonable during the solutioning of this challenge)
1. A User Account with appropriate permissions to the project, used to execute your Terraform.  This user account will have the following permissions:
    - `Google Storage Admin`
    - `Google Container Cluster Admin`
    - `Google Container Admin`
    - `Google Service Account`
    - `Google Compute Admin`
    - `Google Compute InstanceAdmin`
    - `Google NetworkAdmin`
1. An initial bit of code that configures Terraform to run as your user account.
---
## Instructions

To accomplish this challenge, you have been given the above.  You will need to authenticate your `gcloud` cli with the provided account.  See instructions here: [gcloud auth login](https://cloud.google.com/sdk/gcloud/reference/auth/login).  You will also want to configure the `gcloud` cli to set the project. See [gcloud config set](https://cloud.google.com/sdk/gcloud/reference/config/set).

Second, you may create your own repo, or you may fork this repo and add your code to the `kubernetes_cluster_challenge` directory. Remember, Terraform is directory-specific. When running `terraform plan` or `terraform apply` on your code, you'll want to be in the correct directory where you've written your code.  

We have provided a starter `main.tf` file, where you can either write all your configuration code, or you can break your terraform out however you'd like.

Finally, we would like to point out that there are a number of pre-configured terraform modules that *may* assist in this challenge.  If you feel comfortable using the [Google Verified Terraform Modules](https://registry.terraform.io/browse/modules?provider=google&verified=true) to create your cluster, feel free.  However, be aware that this is a simple cluster, and the modules provided by Google are capable of creating *very* complex Kubernetes clusters.  Also, you'll be expected to be able to explain how the publicly-released modules actually work. :)

---
### Enable Project APIs <a name="enable-apis"></a>
Enable the following APIs on the project (use the `google_project_service` resource in Terraform):
- `Compute Engine API`
- `Kubernetes Engine API`
- `Google Container Registry API`
- `Cloud Logging API`
- `Stackdriver Monitoring API`
- `Stackdriver Error Reporting API`
- `Cloud Build API`

---
### Configure Service Account for K8s nodes <a name="create-service-account"></a>
Configure a service account in your project named:

```
[project_id]-kubernetes-worker-nodes-svc
```
It is common best practice to provision service accounts under which your GKE worker nodes run. 

1. Requirements:
    1. This service account should be provisioned with correct [Google IAM Roles](https://cloud.google.com/iam/docs/understanding-roles#kubernetes-engine-roles) to run your nodes. These roles should include:
        1. `roles/container.admin` - enables administration of in-cluster operations (create/destroy pods, etc)
        1. `roles/errorreporting.writer` - enables writing errors to Stackdriver Error Reporting
        1. `roles/logging.logWriter` - enables writing logs to Google Cloud Logging
        1. `roles/monitoring.metricWriter` - enbles writing metrics to Stackdriver
        1. `roles/monitoring.viewer` - enables viewing metrics from Stackdriver, used by service account to read metrics for cluster auto-scaling
        1. `roles/stackdriver.resourceMetadata.writer` - Write-only access to resource metadata. This provides exactly the permissions needed by the Stackdriver metadata agent and other systems that send metadata. 

---
### Create a Google Kubernetes Cluster <a name="create-cluster"></a>

The creation of GKE cluters via Terraform actually creates two resources - a Google-managed Kubernetes master node (one per zone, which unlike vanilla Kubernetes, we never really see), and a `default_node_pool`.  We'd prefer 

1. Requirements:
    1. The Kubernetes Cluster should be a single zone cluster
    1. Disable the `default_node_pool`
    1. Set an `initial_node_count` to 1

---
### Create Node Pools <a name="create-node-pools"></a>
    
We will be creating two node pools, both of which will get managed by the master Kubernetes node. 
1. The first node pool:
    1. Set to a single node
    1. Machine type: `n1-standard-4`
    1. Nodes should be `preemptable`
    1. `legacy_endpoints` should be disabled
1. The second node pool:
    1. Set to a single node
    1. Enable autoscaling with a max of 3 nodes
    1. Machine type: `n1-standard-2`
1. Both node pools should:
    1. Have oAuth Scopes:
        - `"https://www.googleapis.com/auth/logging.write"`
        - `"https://www.googleapis.com/auth/monitoring"`
    1. Run under the Service Account created in [Step #2](#create-service-account)
---

### Create a Google Cloud Storage Bucket <a name="create-storage-bucket"></a>
    
1. Requirements
    1. Give your own account Administrative rights to the Google Cloud Storage bucket
    1. Confirm you can copy/delete files to this bucket using the `gsutil` command ([Google's Cloud Storage command line utility](https://cloud.google.com/storage/docs/gsutil))

---
### Move your Terraform State to use the Backend Bucket <a name="move-state"></a>
    
A "backend" in Terraform determines how state is loaded and how an operation such as apply is executed. Initially, Terraform will store state locally using a `local` backend. This `local` backend is the backend is invoked throughout [Hashicorp's Terraform introduction](https://www.terraform.io/intro/index.html).

However, in any team-based development environment, storage state locally makes cooperative development very difficult. Abstraction of the `backend` enables non-local state file storage, remote execution, etc.

Typically on new Terraform repos, initial configurations are created by a single or pair of developers, who get then create or are provisioned a storage bucket to use as their Terraform backend bucket.  This is an annoying part of spinning up any Terraform project, and it's just good general practice to know how the process works.

---
### Run the Terraform Build!
    
You should be able to, at the end of this work, run both a `terraform plan`, and a `terraform apply` - which will create the resources you've defined in your Terraform configurations.