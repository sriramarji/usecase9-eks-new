output "grafana_url" {
  value = data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname
}

output "prometheus_url" {
  value = data.kubernetes_service.prometheus.status[0].load_balancer[0].ingress[0].hostname
}
