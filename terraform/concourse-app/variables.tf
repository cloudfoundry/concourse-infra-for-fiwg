variable "dr" {
  type = map(string)
  default = {
    credhub_config_name         = "credhub-config"
    credhub_keystore_key_name   = "credhub-keystore-key"
    credhub_encryption_key_name = "credhub-encryption-key"
    credhub_truststore_key_name = "credhub-truststore-key"
  }
}
