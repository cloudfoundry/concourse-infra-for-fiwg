dependency "concourse_app" {
    config_path = "../concourse-app"

    mock_outputs = {
        credhub_config         = "terragrunt mock: no value"
        credhub_keystore_key   = "terragrunt mock: no value"
        credhub_encryption_key = "terragrunt mock: no value"
        credhub_truststore_key = "terragrunt mock: no value"
    }
    mock_outputs_allowed_terraform_commands = ["plan","validate"]
}

inputs = {
    credhub_config         = dependency.concourse_app.outputs.credhub_config
    credhub_keystore_key   = dependency.concourse_app.outputs.credhub_keystore_key
    credhub_encryption_key = dependency.concourse_app.outputs.credhub_encryption_key
    credhub_truststore_key = dependency.concourse_app.outputs.credhub_truststore_key
}

