output "jump_server_id" {
  description = "Jump server IP"
  value       = aws_instance.jump_server.private_ip
}
