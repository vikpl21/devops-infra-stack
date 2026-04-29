output "instance_name" {
  description = "VM instance name"
  value       = google_compute_instance.devops_vm.name
}

output "public_ip" {
  description = "Public IP address of the VM"
  value       = google_compute_instance.devops_vm.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = "ssh ubuntu@${google_compute_instance.devops_vm.network_interface[0].access_config[0].nat_ip}"
}
