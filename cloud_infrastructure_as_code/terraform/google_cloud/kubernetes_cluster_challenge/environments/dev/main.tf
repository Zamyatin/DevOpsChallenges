provider "google" {
  project = var.project_id
  region = "us-central1"
}

# Use a bucket module to create a bucket, we can set versioning to true or false using versioning_enabled flag.
module "state_bucket" {
  source = "../../modules/bucket"
  name = "tf-state-kc-dev"
}

# Enable services in newly created GCP Project.
resource "google_project_service" "gps_enabler" {
  for_each = toset(var.gcp_service_list)

  project = var.project_id
  service = each.key

  disable_dependent_services = true
  depends_on = [module.state_bucket]
}

// Look at public modules repository. registry terraform io look into readme.md

// Naming matters, names need to have a meaningful names so we can easily read them.
// use _ instead of - ( example: gke_node_svc svc means serice account and it would be used for gke node.
//                               gce_elastic or gce_elastic_runner or gce_mysql or gce_mango so basically first part compoment and
//                               then what it does.
//) [DONE]

// Try foreach instead of count which is much cleaner. [DONE]
// [to see the state of the cluster and credentials use `terraform state show google_container_cluster..kubernetes_cluster_primary[\"us-central1-a\"]`]

// Making subdirectories : reorganize and break out directories,
// If I was going to make a project, the project is a directory by its own.
// think about what could be a module.
// Look at Google Project Factory.


# Google Service Account
resource "google_service_account" "gke_svc" {
  account_id = "${var.project_id}-k8s-nodes"
  display_name = "Service account to manage the Kubernetes Cluster."

  depends_on = [module.state_bucket, google_project_service.gps_enabler]
}

// binidng could be safely used with google_folder_* but not safe to use on a project level as it could strip users from their roles.
resource "google_project_iam_member" "gpim" {
  for_each = toset(var.roles)
  member = "serviceAccount:${google_service_account.gke_svc.email}"
  role = each.key
}

# Kubernetes Container Cluster Configuration below.
resource "google_container_cluster" "kubernetes_cluster_primary" {
  for_each = toset(var.k8s_locations)
  name = "my-gke-cluster-${each.key}"
  location = each.key

  remove_default_node_pool = true
  initial_node_count = 1

// Try without the below and see if things work fine. This results in generating cluster_sa_certificate to use for authentication.
//  master_auth {
//    username = ""
//    password = ""
//
//    client_certificate_config {
//      issue_client_certificate = false
//    }
//  }

  depends_on = [google_project_iam_member.gpim]
}

resource "google_container_node_pool" "primary_preemptable_node" {
  for_each = toset(var.k8s_locations)
  name = "my-preemptable-pool"
  location = each.key
  cluster = google_container_cluster.kubernetes_cluster_primary[each.key].name
  node_count = 1

  node_config {
    preemptible = true
    machine_type = "n1-standard-4"

    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  depends_on = [google_container_cluster.kubernetes_cluster_primary]
}

resource "google_container_node_pool" "primary_autoscaling_nodes" {
  for_each = toset(var.k8s_locations)
  name = "my-node-pool"
  location = each.key
  cluster = google_container_cluster.kubernetes_cluster_primary[each.key].name
  node_count = 1
  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }

  node_config {
    machine_type = "n1-standard-2"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  depends_on = [google_container_cluster.kubernetes_cluster_primary]
}

terraform {
    backend "gcs" {
      bucket  = "tf-state-kc-dev"
      prefix  = "terraform/state"
    }
}

