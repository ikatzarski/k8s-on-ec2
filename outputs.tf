output "control_plane_public_ip" {
  value       = aws_instance.control_plane.public_ip
  description = "Public IP of the Control Plane."
}

output "worker_1_public_ip" {
  value       = aws_instance.worker_1.public_ip
  description = "Public IP of the Worker 1 Node."
}
