output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet1a_id" {
  value = aws_subnet.subnet1a.id
}

output "subnet1c_id" {
  value = aws_subnet.subnet1c.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}