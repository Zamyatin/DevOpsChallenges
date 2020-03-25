# Creates a bucket.

resource "google_storage_bucket" "mybucket" {
  name = var.name


  #encryption {
  #  default_kms_key_name = "default_kms_key_name"
  #}

  versioning {enabled = var.versioning_enabled}



}