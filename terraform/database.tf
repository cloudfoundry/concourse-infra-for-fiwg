# resource "google_sql_database" "tfer--concourse-concourse" {
#   charset   = "UTF8"
#   collation = "en_US.UTF8"
#   instance  = "concourse"
#   name      = "concourse"
#   project   = "cloud-foundry-310819"
# }

# resource "google_sql_database" "tfer--concourse-credhub" {
#   charset   = "UTF8"
#   collation = "en_US.UTF8"
#   instance  = "concourse"
#   name      = "credhub"
#   project   = "cloud-foundry-310819"
# }

# resource "google_sql_database" "tfer--concourse-postgres" {
#   charset   = "UTF8"
#   collation = "en_US.UTF8"
#   instance  = "concourse"
#   name      = "postgres"
#   project   = "cloud-foundry-310819"
# }

# resource "google_sql_database" "tfer--concourse-uaa" {
#   charset   = "UTF8"
#   collation = "en_US.UTF8"
#   instance  = "concourse"
#   name      = "uaa"
#   project   = "cloud-foundry-310819"
# }

resource "google_sql_database_instance" "concourse" {
  database_version = "POSTGRES_13"
  name             = var.db_instance
  project          = var.project
  region           = var.region

  settings {
    activation_policy = "ALWAYS"
    availability_type = "REGIONAL"

    backup_configuration {
      backup_retention_settings {
        retained_backups = "7"
        retention_unit   = "COUNT"
      }

      binary_log_enabled             = "false"
      enabled                        = "true"
      point_in_time_recovery_enabled = "true"
      start_time                     = "00:00"
      transaction_log_retention_days = "7"
    }

    disk_autoresize       = "true"
    disk_autoresize_limit = "0"
    disk_size             = "37"
    disk_type             = "PD_SSD"

    ip_configuration {
      ipv4_enabled = "true"
      require_ssl  = "false"
    }

    location_preference {
      zone = var.zone
    }

    pricing_plan = "PER_USE"
    tier         = "db-custom-1-4096"

  }
}
