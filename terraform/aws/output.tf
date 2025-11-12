output "lb_url" {
  value       = "http://${module.compute.elb_dns_name}"
  description = "URL pública do Load Balancer"
}