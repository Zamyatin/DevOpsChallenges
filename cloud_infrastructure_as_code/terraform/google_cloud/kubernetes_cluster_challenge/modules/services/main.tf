

# Enable services in newly created GCP Project.
resource "google_project_service" "gps_enabler" {
  for_each = toset(var.gcp_service_list)

  project = var.project_id
  service = each.key

  disable_dependent_services = true
//  depends_on = [module.state_bucket]
}