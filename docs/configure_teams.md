# Configuring Concourse Teams

This document explains how to configure Concourse teams using YAML files stored in the `../teams` directory. Each team should have its own YAML configuration file (for example, `../teams/main.yml`).

## Applying Team Configuration

To apply a team's configuration, use the `fly` CLI with the `set-team` command, referencing the appropriate file:

```sh
fly -t <target> set-team -n main --config ../teams/main.yml
```

Repeat this process for each team file in the `../teams` directory.