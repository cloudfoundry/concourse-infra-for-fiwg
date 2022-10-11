variable "credhub_encryption_key" {
     default = {
        binary_data = {
            password = ""
        }
     }
}

variable "credhub_config" {
    default = {
        binary_data = {
            "application.yml" = ""
        }
    }
}

variable "credhub_keystore_key" {
     default = {
        binary_data = {
            password = ""
        }
     }
}

variable "credhub_truststore_key" {
     default = {
        binary_data = {
            password = ""
        }
     }
}

variable "dr" {
  type = map(string)
  default = {
    credhub_config_name         = "credhub-config"
    credhub_keystore_key_name   = "credhub-keystore-key"
    credhub_encryption_key_name = "credhub-encryption-key"
    credhub_truststore_key_name = "credhub-truststore-key"
  }
}
