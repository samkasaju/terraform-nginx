output "urls" {
  value = { for k, m in module.nginx : k => m.url }
}
