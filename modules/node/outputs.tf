output "public_ip" {
  description = "The public IP of the node."
  value       = aws_instance.main.public_ip
}
