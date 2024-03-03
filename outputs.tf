output "control_plane_public_ip" {
  description = "Public IP of the Control Plane."
  value       = module.control_plane.public_ip
}

output "worker_public_ip" {
  description = "Public IP of the Workers."
  value       = values(module.worker)[*].public_ip
}

output "private_key" {
  description = "The private key needed to SSH into the nodes."
  value       = tls_private_key.main.private_key_pem
  sensitive   = true
}
