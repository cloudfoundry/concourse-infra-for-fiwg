# --- credhub encryption key
data "google_secret_manager_secret" "credhub_encryption_key" {
  secret_id = var.dr.credhub_encryption_key_name
  project   = var.project
}

data "google_secret_manager_secret_version" "credhub_encryption_key" {
  project = var.project
  secret  = "${var.gke.name}-${var.dr.credhub_encryption_key_name}"
}

resource "kubernetes_secret_v1" "credhub_encryption_key_restored" {
  metadata {
    name      = var.dr.credhub_encryption_key_name
    namespace = var.concourse_app.namespace
  }

  data = {
    password = data.google_secret_manager_secret_version.credhub_encryption_key.secret_data
  }
}

# --- credhub config
data "google_secret_manager_secret" "credhub_config" {
  secret_id = var.dr.credhub_config_name
  project   = var.project
}

data "google_secret_manager_secret_version" "credhub_config" {
  secret  = "${var.gke.name}-${var.dr.credhub_config_name}"
  project = var.project
}

resource "kubernetes_secret_v1" "credhub_config_restored" {

  metadata {
    name      = var.dr.credhub_config_name
    namespace = var.concourse_app.namespace
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

resource "google_sql_user" "sql_user_pass_restored" {
  instance = var.sql_instance_name
  project  = var.project
  for_each = toset(var.sql_database)

  # in this case we have the same names for users and dbs
  name     = each.key
  password = base64decode(data.kubernetes_secret_v1.sql_user_password[each.key].binary_data.password)

  lifecycle {
    ignore_changes = all
  }

}

