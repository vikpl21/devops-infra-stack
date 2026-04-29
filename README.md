# DevOps Infrastructure Stack

> **Production-grade infrastructure automation** using Terraform, Ansible, and ELK Stack on GCP.
> Built as a portfolio project demonstrating end-to-end DevOps practices: IaC provisioning → configuration management → observability.

---

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   LOCAL MACHINE                      │
│                                                      │
│  ┌─────────────┐          ┌─────────────────────┐   │
│  │  Terraform  │─────────▶│   GCP Infrastructure │   │
│  │    (IaC)    │          │                      │   │
│  └─────────────┘          │  ┌───────────────┐   │   │
│                           │  │  VPC Network  │   │   │
│  ┌─────────────┐          │  ├───────────────┤   │   │
│  │   Ansible   │─────────▶│  │    Subnet     │   │   │
│  │  (Config)   │   SSH    │  ├───────────────┤   │   │
│  └─────────────┘          │  │   Firewall    │   │   │
│                           │  ├───────────────┤   │   │
└───────────────────────────│  │  VM e2-medium │   │   │
                            │  │ Ubuntu 22.04  │   │   │
                            │  └───────┬───────┘   │   │
                            │          │            │   │
                            │  ┌───────▼───────┐   │   │
                            │  │   ELK Stack   │   │   │
                            │  │  (Docker)     │   │   │
                            │  ├───────────────┤   │   │
                            │  │ Elasticsearch │◀──│───│── logs / API :9200
                            │  │   Logstash    │   │   │  pipeline   :5044
                            │  │    Kibana     │◀──│───│── UI        :5601
                            │  └───────────────┘   │   │
                            └─────────────────────-┘   │
                                                        │
```

---

## Stack

| Tool | Version | Purpose |
|------|---------|---------|
| **Terraform** | >= 1.5 | GCP infrastructure provisioning (VPC, Subnet, Firewall, VM) |
| **Ansible** | >= 2.9 | Server configuration & application deployment |
| **Elasticsearch** | 8.13.0 | Log storage, indexing and search engine |
| **Logstash** | 8.13.0 | Log ingestion and processing pipeline |
| **Kibana** | 8.13.0 | Log visualization and dashboards |
| **Docker Compose** | v2 | ELK container orchestration on VM |
| **GCP** | — | Cloud provider (europe-central2 / Warsaw) |

---

## Prerequisites

- GCP account with billing enabled
- `gcloud` CLI installed and authenticated (`gcloud auth application-default login`)
- Terraform >= 1.5 installed
- Ansible >= 2.9 installed
- Ansible Docker collection: `ansible-galaxy collection install community.docker`
- SSH key pair at `~/.ssh/id_rsa` / `~/.ssh/id_rsa.pub`

---

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/vikpl21/devops-infra-stack.git
cd devops-infra-stack
```

### 2. Enable GCP Compute Engine API

```bash
gcloud services enable compute.googleapis.com --project=YOUR_PROJECT_ID
```

### 3. Provision Infrastructure with Terraform

```bash
cd terraform/

# Create your variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars — set your GCP project_id

terraform init
terraform plan
terraform apply
```

Expected output:
```
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:
instance_name = "devops-demo-vm"
public_ip     = "34.x.x.x"
ssh_command   = "ssh ubuntu@34.x.x.x"
```

### 4. Configure Server with Ansible

```bash
cd ../ansible/

# Create inventory from template
cp inventory/hosts.ini.example inventory/hosts.ini
# Edit hosts.ini — paste your VM public IP from terraform output

# Step 1: Install Docker
ansible-playbook -i inventory/hosts.ini playbooks/install_docker.yml

# Step 2: Deploy ELK Stack
ansible-playbook -i inventory/hosts.ini playbooks/install_elk.yml
```

### 5. Access Services

```bash
# Verify Elasticsearch is running
curl http://YOUR_VM_IP:9200

# Open Kibana dashboard in browser
http://YOUR_VM_IP:5601
```

---

## Project Structure

```
devops-infra-stack/
│
├── terraform/
│   ├── main.tf                   # GCP resources: VPC, Subnet, Firewall, VM
│   ├── variables.tf              # Input variables with defaults
│   ├── outputs.tf                # Outputs: instance name, public IP, SSH command
│   ├── terraform.tfvars.example  # Template for project_id variable
│   └── .terraform.lock.hcl      # Provider version lock file
│
├── ansible/
│   ├── inventory/
│   │   └── hosts.ini.example     # Inventory template (copy and fill IP)
│   └── playbooks/
│       ├── install_docker.yml    # Install Docker CE + Docker Compose plugin
│       └── install_elk.yml       # Deploy ELK Stack via Docker Compose
│
└── README.md
```

---

## Infrastructure Details

| Parameter | Value |
|-----------|-------|
| Cloud Provider | GCP |
| Region | europe-central2 (Warsaw) |
| VM Type | e2-medium (2 vCPU, 4 GB RAM) |
| OS | Ubuntu 22.04 LTS |
| Disk | 20 GB |
| Network | Custom VPC + Subnet 10.0.1.0/24 |
| Firewall | TCP: 22, 80, 443, 5601, 9200 |

---

## Key Concepts Demonstrated

- **Infrastructure as Code** — entire GCP infrastructure defined in `.tf` files; reproducible with one command
- **Idempotency** — Ansible playbooks can be re-run safely; no duplicate installations
- **Dependency graph** — Terraform resolves resource creation order automatically (VPC → Subnet → Firewall → VM)
- **Separation of concerns** — Terraform provisions infrastructure, Ansible configures it
- **Security baseline** — SSH key authentication, `.gitignore` excludes secrets and state files

---

## Cost Management

Stop the VM when not in use to avoid unnecessary GCP charges:

```bash
# Stop VM (preserves disk and config)
gcloud compute instances stop devops-demo-vm \
  --zone=europe-central2-a --project=YOUR_PROJECT_ID

# Start VM again
gcloud compute instances start devops-demo-vm \
  --zone=europe-central2-a --project=YOUR_PROJECT_ID

# Check new public IP after start
cd terraform && terraform output public_ip
```

> ⚠️ Public IP may change after restart. Always verify with `terraform output public_ip`.

---

## Destroy Infrastructure

```bash
cd terraform/
terraform destroy
```

---

## Screenshots

### Kibana Dashboard — Log Analytics
![Kibana Dashboard](docs/kibana-dashboard.png)

### Kibana Discover — Log Stream  
![Kibana Discover](docs/kibana-discover.png)


## Roadmap

- [x] Terraform: GCP VPC + VM provisioning
- [x] Ansible: Docker installation playbook
- [x] Ansible: ELK Stack deployment playbook
- [ ] Ansible: Linux hardening playbook
- [ ] HashiCorp Vault: secrets management layer
- [ ] Grafana: infrastructure monitoring dashboards
- [ ] GitHub Actions: CI/CD pipeline for infrastructure validation

---

## Author

DevOps Engineer | Linux | CI/CD | Cloud

[![GitHub](https://img.shields.io/badge/GitHub-vikpl21-black?logo=github)](https://github.com/vikpl21)

