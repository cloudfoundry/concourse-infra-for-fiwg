resource "google_storage_bucket" "terraform-state-wg-ci" {
  default_event_based_hold = "false"
  force_destroy            = "false"

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age                        = "0"
      created_before             = ""
      days_since_custom_time     = "0"
      days_since_noncurrent_time = "0"
      num_newer_versions         = "10"
      with_state                 = "ARCHIVED"
    }
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      age                        = "0"
      created_before             = ""
      days_since_custom_time     = "0"
      days_since_noncurrent_time = "7"
      num_newer_versions         = "0"
      with_state                 = "ANY"
    }
  }

  location                    = var.region
  name                        = var.gcs_state_bucket
  project                     = var.project
  requester_pays              = "false"
  storage_class               = "STANDARD"
  uniform_bucket_level_access = "true"

  versioning {
    enabled = "true"
  }
}