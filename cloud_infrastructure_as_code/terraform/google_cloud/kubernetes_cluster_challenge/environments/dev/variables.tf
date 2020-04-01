variable "project_id" {
  type = string
}

variable "regions" {
  type = list(string)
}

variable "k8s_locations" {
  type = list(string)
}

variable "gcp_service_list" {
  type = list(string)
}

variable "roles" {
  type = list(string)
}