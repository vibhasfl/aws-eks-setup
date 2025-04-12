output "jump_server_id" {
  description = "Jump server IP"
  value       = aws_instance.jump_server.private_ip
}

output "jump_server_role" {
  value       = aws_iam_role.ec2_ssm_role.arn
  description = "Jump server role"
}
