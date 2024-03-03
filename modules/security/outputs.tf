output "control_plane_security_group_id" {
  description = "The ID of the control plane security group."
  value       = aws_security_group.control_plane.id
}

output "worker_security_group_id" {
  description = "The ID of the worker security group."
  value       = aws_security_group.worker.id
}
