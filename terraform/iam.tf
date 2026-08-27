# 1. Сервисный аккаунт для Master Control Plane
resource "yandex_iam_service_account" "cluster_sa" {
  name        = "${var.cluster_name}-master-sa"
  description = "Сервисный аккаунт для управления кластером Kubernetes"
}

# Роль агента управления кластером
resource "yandex_resourcemanager_folder_iam_member" "cluster_agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.cluster_sa.id}"
}

# Роль для управления публичными IP и балансировщиками
resource "yandex_resourcemanager_folder_iam_member" "vpc_public_admin" {
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.cluster_sa.id}"
}

# Роль для создания Yandex Network Load Balancer
resource "yandex_resourcemanager_folder_iam_member" "alb_editor" {
  folder_id = var.folder_id
  role      = "load-balancer.admin"
  member    = "serviceAccount:${yandex_iam_service_account.cluster_sa.id}"
}

# 2. Сервисный аккаунт для Worker Nodes
resource "yandex_iam_service_account" "nodes_sa" {
  name        = "${var.cluster_name}-nodes-sa"
  description = "Сервисный аккаунт для рабочих нод Kubernetes"
}

# Роль Zero-Secret Pull: позволяет нодам скачивать образы из YCR без секретов
resource "yandex_resourcemanager_folder_iam_member" "images_puller" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.nodes_sa.id}"
}
