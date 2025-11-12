output "lb_fqdn" {
  value       = "http://${module.compute.lb_fqdn}"
  description = "URL pública do Load Balancer"
}