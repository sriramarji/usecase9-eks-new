output "grafana_url" {
  value = helm_release.prometheus.status[0].resources["Service/grafana"].metadata[0].name
}

output "prometheus_url" {
  value = helm_release.prometheus.status[0].resources["Service/prometheus-kube-prometheus-prometheus"].metadata[0].name
}
