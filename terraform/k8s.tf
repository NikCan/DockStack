# Managed Kubernetes Master (Zonal)
resource "yandex_kubernetes_cluster" "main" {
  name        = var.cluster_name
  description = "Managed Kubernetes cluster created by Terraform"
  network_id  = yandex_vpc_network.main.id

  master {
    version = var.k8s_version
    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.k8s_subnet.id
    }

    public_ip          = true
    security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
  }

  service_account_id      = yandex_iam_service_account.cluster_sa.id
  node_service_account_id = yandex_iam_service_account.nodes_sa.id

  labels = local.common_labels

  depends_on = [
    yandex_resourcemanager_folder_iam_member.cluster_agent,
    yandex_resourcemanager_folder_iam_member.vpc_public_admin,
    yandex_resourcemanager_folder_iam_member.images_puller
  ]
}

# Managed Node Group
resource "yandex_kubernetes_node_group" "main_nodes" {
  cluster_id  = yandex_kubernetes_cluster.main.id
  name        = "${var.cluster_name}-nodes"
  description = "Рабочие ноды кластера"
  version     = var.k8s_version

  instance_template {
    platform_id = "standard-v3" # Intel Ice Lake (2 vCPU, 4-8 GB RAM)

    resources {
      cores         = var.node_cores
      memory        = var.node_memory
      core_fraction = 100
    }

    boot_disk {
      type = "network-ssd"
      size = var.node_disk_size
    }

    scheduling_policy {
      preemptible = var.preemptible_nodes # прерываемые ноды экономят до 60% бюджета
    }

    network_interface {
      nat                = false # ноды приватные, выход в сеть через NAT Gateway
      subnet_ids         = [yandex_vpc_subnet.k8s_subnet.id]
      security_group_ids = [yandex_vpc_security_group.k8s_sg.id]
    }
  }

  scale_policy {
    fixed_scale {
      size = var.node_count
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = false
    auto_repair  = true
  }

  labels = local.common_labels
}
