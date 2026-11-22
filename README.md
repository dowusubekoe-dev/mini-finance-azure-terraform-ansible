# Mini Finance on Azure — Terraform + Ansible Deployment

End-to-end deployment of the Mini Finance website to Microsoft Azure: **Terraform** provisions the infrastructure and an **Ansible** playbook configures the server, deploys the site, and verifies it is live.

> **Project context:** Built during the Cloud DevOps Bootcamp (The CloudAdvisory Oy, 2026), week 11 (Ansible module). The Mini Finance site itself is a coursework application (from pravinmishraaws/mini_finance); this repo is the deployment automation around it. The deployment is executed by running Terraform and Ansible directly — this repo contains no CI/CD pipeline definitions.

## What gets deployed

**Terraform (`terraform/`)** — azurerm provider:

- Resource group, virtual network (10.0.0.0/16) and subnet (10.0.1.0/24)
- Network security group (inbound SSH 22, HTTP 80, HTTPS 443)
- Public IP and network interface
- Ubuntu 22.04 LTS virtual machine (Standard_D2s_v3), exported as the `public_ip` output

**Ansible (`ansible/site.yml`)** — three plays:

1. **Install and configure Nginx** — apt update, install Nginx and git, start and enable the service
2. **Clone and deploy the Mini Finance site** — clones the application repository into `/var/www/html/`, sets `www-data` ownership, reloads Nginx
3. **Verify deployment** — HTTP check from the control node asserting the site returns status 200

## Repository structure

```
├── terraform/
│   ├── providers.tf            # azurerm provider
│   ├── main.tf                 # RG, VNet, subnet, NSG, public IP, NIC, VM
│   ├── variables.tf            # admin_username, admin_password (sensitive, no default)
│   ├── output.tf               # public_ip output
│   └── terraform.tfvars.example # Sample values — copy to terraform.tfvars
├── ansible/
│   ├── ansible.cfg
│   ├── inventory.ini           # VM address (placeholder — set from terraform output)
│   └── site.yml                # install → deploy → verify
└── requirements.txt            # Lint tooling used during the coursework (ansible-lint, yamllint)
```

## How to run it

Prerequisites: Terraform >= 1.5, Ansible, an SSH key pair at `~/.ssh/id_ed25519(.pub)`, and the Azure CLI authenticated (`az login`) with a subscription that can create one VM.

```bash
# 1. Provision
cd terraform
cp terraform.tfvars.example terraform.tfvars   # then set your own admin_password
terraform init
terraform apply

# 2. Point the inventory at the new VM
#    edit ../ansible/inventory.ini with the public_ip output

# 3. Configure and deploy
cd ../ansible
ansible-playbook -i inventory.ini site.yml
```

Secrets handling: the VM admin password is a sensitive variable with **no default in code** — it is supplied only through your local `terraform.tfvars`, which is git-ignored along with all state files (see `.gitignore`).

## Skills demonstrated

Terraform (azurerm) infrastructure as code, Azure networking (VNet, subnet, NSG, public IP, NIC), Linux VM provisioning, Ansible playbooks with handlers and verification checks, Nginx deployment of a static site, and secrets/state hygiene for public code.
