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