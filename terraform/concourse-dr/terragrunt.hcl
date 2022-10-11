dependency "concourse_app" {
    config_path = "../concourse-app"

    mock_outputs = {
        credhub_encryption_key = "terragrunt mock: no value"
        credhub_config         = "terragrunt mock: no value"
    }
    mock_outputs_allowed_terraform_commands = ["plan","validate"]
}

inputs = {
    credhub_encryption_key = dependency.concourse_app.outputs.credhub_encryption_key
    credhub_config         = dependency.concourse_app.outputs.credhub_config
}