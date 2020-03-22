# Let's build a Google Kubenetes Engine (GKE) Cluster!

The goal of this excercise is to build a simple Kubernetes cluster by writing some Terraform Code. 

To get you underway, you will be provisioned a few things:
- A Google Project, which will have some budget constraints (so we can keep costs reasonable during the solutioning of this challenge)
- A user account with appropriate permissions to the project, used to execute your Terraform
- An initial bit of code that configures Terraform to run as your user account.


Challenges:

1. Enable the following APIs on the project (use the `google_project_service` resource):
    1. Compute Engine API
    1. Kubernetes Engine API
    1. Google Container Registry API
    1. Cloud Logging API
    1. Stackdriver Monitoring API
    1. Stackdriver Error Reporting API
    1. Cloud Build API

1. Configure a service account in your project named:
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

1. Create a Google Kubernetes Cluster

    The creation of GKE cluters via Terraform actually creates two resources - a Google-managed Kubernetes master node (one per zone, which unlike vanilla Kubernetes, we never really see)
    
    1. Requirements:
        1. The Kubernetes Cluster should be a single zone cluster
        1. By default, GKE wants to create
        1. 
