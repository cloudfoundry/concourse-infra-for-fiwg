variable "dr" {
  type = map(bool)
  default = {
    # false indicates no restore action will be taken
    credhub_restore_encryption_password = false
    credhub_restore_config              = false
    sql_users_restore_passwords         = false
  }

}

# --- credhub encryption key

data "google_secret_manager_secret_version" "credhub_encryption_key" {
  secret = google_secret_manager_secret.credhub_encryption_key.name
}

resource "kubernetes_secret_v1" "credhub_encryption_key_restored" {
  count = var.dr.credhub_restore_encryption_password ? 1 : 0

  metadata {
    name      = "credhub-encryption-key"
    namespace = "concourse"
  }

  data = {
    password = data.google_secret_manager_secret_version.credhub_encryption_key.secret_data
  }
}

# --- credhub config

data "google_secret_manager_secret_version" "credhub_config" {
  secret = google_secret_manager_secret.credhub_config.name
}

resource "kubernetes_secret_v1" "credhub_config_restored" {
  count = var.dr.credhub_restore_config ? 1 : 0

  metadata {
    name      = "credhub-config"
    namespace = "concourse"
  }

  data = {
    "application.yml" = data.google_secret_manager_secret_version.credhub_config.secret_data
  }
}


# --- SQL user passwords

data "kubernetes_secret_v1" "sql_user_password" {

  for_each = toset(var.sql_database)

  metadata {
    name      = "${each.key}-postgresql-password"
    namespace = "concourse"
  }

  binary_data = {
    "password" = ""
  }
}

resource "google_sql_user" "concourse_user_pass_restored" {

  # need separate entries for each user
  # since count and for_each can't be used together
  count = var.dr.sql_users_restore_passwords ? 1 : 0

  instance = var.sql_instance_name
  project = var.project
  name = "concourse"
  password = base64decode(data.kubernetes_secret_v1.sql_user_password["concourse"].binary_data.password)

  lifecycle {
    ignore_changes = all
  }

}

resource "google_sql_user" "uaa_user_pass_restored" {

  # need separate entries for each user
  # since count and for_each can't be used together
  count = var.dr.sql_users_restore_passwords ? 1 : 0

  instance = var.sql_instance_name
  project = var.project
  name = "uaa"
  password = base64decode(data.kubernetes_secret_v1.sql_user_password["uaa"].binary_data.password)

  lifecycle {
    ignore_changes = all
  }

}

resource "google_sql_user" "credhub_user_pass_restored" {

  # need separate entries for each user
  # since count and for_each can't be used together
  count = var.dr.sql_users_restore_passwords ? 1 : 0

  instance = var.sql_instance_name
  project = var.project
  name = "credhub"
  password = base64decode(data.kubernetes_secret_v1.sql_user_password["credhub"].binary_data.password)

  lifecycle {
    ignore_changes = all
  }

}

