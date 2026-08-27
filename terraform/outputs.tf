output "k8s_cluster_id" {
  description = "ID созданного кластера Kubernetes"
  value       = yandex_kubernetes_cluster.main.id
}

output "k8s_cluster_name" {
  description = "Имя кластера Kubernetes"
  value       = yandex_kubernetes_cluster.main.name
}

output "k8s_external_endpoint" {
  description = "Публичный адрес API-сервера Kubernetes"
  value       = yandex_kubernetes_cluster.main.master[0].external_v4_endpoint
}

output "container_registry_id" {
  description = "ID созданного Yandex Container Registry"
  value       = yandex_container_registry.main.id
}

output "container_registry_url" {
  description = "URL адрес реестра для тегирования и пуша образов"
  value       = "cr.yandex/${yandex_container_registry.main.id}"
}

output "configure_kubectl" {
  description = "Команда для настройки подключения kubectl к кластеру"
  value       = "yc managed-kubernetes cluster get-credentials --id ${yandex_kubernetes_cluster.main.id} --external --force"
}
