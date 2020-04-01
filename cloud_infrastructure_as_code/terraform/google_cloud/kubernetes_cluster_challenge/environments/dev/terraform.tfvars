//- `Compute Engine API`
//- `Google Container Registry API`
//- `Cloud Logging API`
//- `Stackdriver Monitoring API`
//- `Stackdriver Error Reporting API`
//- `Cloud Build API`
//- `Kubernetes Engine API`

project_id = "kubernetes-challenge"

regions = ["us-central1"]

k8s_locations = ["us-central1-a"]

gcp_service_list = [
  "oslogin.googleapis.com",
  "container.googleapis.com",
  "compute.googleapis.com",
  "containerregistry.googleapis.com",
  "logging.googleapis.com",
  "stackdriver.googleapis.com",
  "clouderrorreporting.googleapis.com",
  "cloudbuild.googleapis.com",
  "compute.googleapis.com"
]

roles = [
  "roles/container.admin",
  "roles/errorreporting.writer",
  "roles/logging.logWriter",
  "roles/monitoring.metricWriter",
  "roles/monitoring.viewer",
  "roles/stackdriver.resourceMetadata.writer"
]