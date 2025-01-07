output "id" {
  description = "The ID of the instance"
  value       = try(module.ec2_instance.id, "")
}

output "arn" {
  description = "The ARN of the instance"
  value       = try(module.ec2_instance.arn, "")
}

output "instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = try(module.ec2_instance.instance_state, "")
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = try(module.ec2_instance.private_ip, "")
}