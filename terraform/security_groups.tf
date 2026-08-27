# Единая группа безопасности для кластера и нод
resource "yandex_vpc_security_group" "k8s_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Правила безопасности для Managed K8s кластера и рабочих нод"
  network_id  = yandex_vpc_network.main.id
  labels      = local.common_labels

  # Разрешить весь трафик между нодами и мастером внутри группы
  ingress {
    protocol          = "ANY"
    description       = "Связь мастер-нода и нода-нода"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  egress {
    protocol          = "ANY"
    description       = "Связь мастер-нода и нода-нода (исходящий)"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  # Доступ к Kubernetes API (443 и 6443) отовсюду
  ingress {
    protocol       = "TCP"
    description    = "Доступ к Kubernetes API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "Доступ к Kubernetes API порт 6443"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }

  # Health checks от Yandex Network Load Balancer
  ingress {
    protocol          = "TCP"
    description       = "NLB health checks"
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }

  # Публичный трафик Ingress (HTTP 80 и HTTPS 443)
  ingress {
    protocol       = "TCP"
    description    = "HTTP Ingress"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS Ingress"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # Трафик от Network Load Balancer к NodePort сервисам
  ingress {
    protocol       = "TCP"
    description    = "NodePort range for Ingress / LoadBalancer"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 30000
    to_port        = 32767
  }

  # Разрешить весь исходящий трафик в интернет
  egress {
    protocol       = "ANY"
    description    = "Исходящий трафик в интернет"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }
}
