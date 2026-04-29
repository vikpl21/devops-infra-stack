variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-central2" # Варшава — найближче до тебе
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-central2-a"
}

variable "instance_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "devops-demo-vm"
}

variable "machine_type" {
  description = "GCP machine type"
  type        = string
  default     = "e2-medium" # Free tier!
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  default     = ""
}
