# Azure with Terraform & Ansible

### Terraform Concepts
For Infrastructure as Code (IaC) and Terraform concepts, see [Terraform Concepts](./docs/terraform-concepts.md)

### Infrastructure as Code
Infrastructure as Code allows us to use a high level or descriptive programming language to describe and manage infrastructure.

There is a known issue called environment drift, which means that over time, an environment can end up in unique configuration that cannot be automatically recreated.

When environments become inconsistent, deployments can be affected and testing can be made invalid.

With infrastructure as code, the infrastructure configurations can be versioned and maintained, so if another environment needs to be created, you can be sure that you are using up to date configurations.

## Project Setup
### `init.sh`
There is an `init.sh` script at the root of the project that is intended to be sourced (`source init.sh`) every time you are in a new shell on the project.
This will configure an `azurerm` backend for storing the `terraform.tftstate` file.

