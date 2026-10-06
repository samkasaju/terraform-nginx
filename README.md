<img width="923" height="588" alt="image" src="https://github.com/user-attachments/assets/68901ebb-3057-4dcf-974c-e8de6a1b8187" />
<img width="923" height="588" alt="Screenshot from 2026-10-06 12-33-28" src="https://github.com/user-attachments/assets/fdefd216-578a-423d-a460-64e47b0b3a1b" />
# Terraform NGINX Infrastructure

A small Infrastructure as Code (IaC) project using **Terraform** and the **Docker provider** to create two NGINX containers.

The project demonstrates reusable Terraform modules, variables, locals, `for_each`, outputs, state management, and GitHub Actions CI.

## Architecture

```text
                         Terraform
                             |
                    Root configuration
                             |
                        for_each
                       /        \
                      /          \
              site-one          site-two
                 |                  |
           NGINX module        NGINX module
                 |                  |
            tf-site-one        tf-site-two
                 |                  |
        localhost:8081       localhost:8082
```

Each NGINX container is created from the same reusable Terraform module.

## Project Structure

```text
terraform-nginx/
├── main.tf
├── variables.tf
├── outputs.tf
├── .gitignore
├── .terraform.lock.hcl
├── modules/
│   └── nginx/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── .github/
    └── workflows/
        └── terraform.yml
```

## Technologies Used

* Terraform
* Docker
* NGINX
* Git
* GitHub
* GitHub Actions
* Terraform Docker Provider (`kreuzwerker/docker`)

## Terraform Concepts Demonstrated

### Variables

The root configuration defines the NGINX sites and their external ports:

```hcl
variable "sites" {
  type = map(number)

  default = {
    site-one = 8081
    site-two = 8082
  }
}
```

The module also accepts variables for the container name, port, and Docker image.

### Locals

A local value is used to create a common container-name prefix:

```hcl
locals {
  prefix = "tf"
}
```

This produces names such as:

```text
tf-site-one
tf-site-two
```

### Modules

The NGINX container configuration is stored in a reusable module:

```text
modules/nginx/
```

The root configuration calls the module instead of duplicating the Docker resource configuration.

### for_each

The module is created once for every entry in the `sites` map:

```hcl
module "nginx" {
  source        = "./modules/nginx"
  for_each      = var.sites
  name          = "${local.prefix}-${each.key}"
  external_port = each.value
}
```

This creates two module instances:

```text
module.nginx["site-one"]
module.nginx["site-two"]
```

### Outputs

The root output collects the URL from every module:

```hcl
output "urls" {
  value = { for k, m in module.nginx : k => m.url }
}
```

The resulting output is:

```text
site-one = http://localhost:8081
site-two = http://localhost:8082
```

## How It Works

Terraform uses the Docker provider to manage Docker images and containers.

The NGINX module:

1. Downloads or uses the `nginx:latest` Docker image.
2. Creates an NGINX container.
3. Maps container port `80` to an external host port.
4. Returns the URL as a Terraform output.

The root configuration uses `for_each` to create two instances of the module.

## Running the Project

### 1. Format the configuration

```bash
terraform fmt -recursive
```

Check formatting:

```bash
terraform fmt -check -recursive
```

### 2. Initialize Terraform

```bash
terraform init
```

This downloads the required Docker provider and creates `.terraform.lock.hcl`.

### 3. Validate the configuration

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

### 4. Preview the infrastructure

```bash
terraform plan
```

The plan should show four resources to be created:

```text
2 Docker images
2 Docker containers
```

### 5. Create the infrastructure

```bash
terraform apply
```

Type:

```text
yes
```

Terraform should report:

```text
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

## Verify the Containers

Run:

```bash
docker ps
```

Expected containers:

```text
tf-site-one
tf-site-two
```

Expected port mappings:

```text
0.0.0.0:8081->80/tcp
0.0.0.0:8082->80/tcp
```

Open the applications in a browser:

```text
http://localhost:8081
http://localhost:8082
```

Both should display the NGINX welcome page.

To view the Terraform outputs:

```bash
terraform output
```

## Terraform State

Terraform creates a state file:

```text
terraform.tfstate
```

The state records the infrastructure Terraform is managing.

State files are excluded from Git using `.gitignore`:

```text
.terraform/
*.tfstate
*.tfstate.backup
```

The provider lock file is intentionally tracked:

```text
.terraform.lock.hcl
```

## GitHub Actions

The project includes a GitHub Actions workflow:

```text
.github/workflows/terraform.yml
```

The workflow runs on pushes and pull requests.

It performs:

```text
Terraform format check
        ↓
Terraform init
        ↓
Terraform validate
```

Workflow configuration:

```yaml
name: Terraform CI

on:
  push:
  pull_request:

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: hashicorp/setup-terraform@v3

      - run: terraform fmt -check -recursive

      - run: terraform init

      - run: terraform validate
```

This provides a basic CI check so invalid or incorrectly formatted Terraform changes can be detected before merging.

## Cleanup

To remove the Docker infrastructure created by Terraform:

```bash
terraform destroy
```

Type:

```text
yes
```

Terraform will remove the containers and other resources it manages.

## What I Learned

This project demonstrates Infrastructure as Code using Terraform.

I used:

* **Variables** to define configurable site ports.
* **Locals** to create reusable naming values.
* **Modules** to make the NGINX configuration reusable.
* **`for_each`** to create one module instance for each site.
* **Outputs** to display the URLs of the deployed containers.
* **Terraform state** to track managed infrastructure.
* **GitHub Actions** to automatically run Terraform formatting, initialization, and validation checks.

## Final Result

The Terraform configuration creates two NGINX containers:

| Site     | Container     | Port | URL                     |
| -------- | ------------- | ---: | ----------------------- |
| site-one | `tf-site-one` | 8081 | `http://localhost:8081` |
| site-two | `tf-site-two` | 8082 | `http://localhost:8082` |

The infrastructure can be created, verified, and removed using Terraform commands, 
while GitHub Actions automatically checks the Terraform configuration on repository 
changes.
