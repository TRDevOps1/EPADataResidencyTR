output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block allocated to the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_cidr_blocks" {
  description = "CIDR blocks allocated to the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidr_blocks" {
  description = "CIDR blocks allocated to the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "availability_zones" {
  description = "Availability Zones containing the subnets"
  value       = local.availability_zones
}

output "domain_controller_private_ips" {
  description = "Private IP addresses reserved for domain controllers"
  value = [
    cidrhost(aws_subnet.private[0].cidr_block, 10),
    cidrhost(aws_subnet.private[1].cidr_block, 10)
  ]
}