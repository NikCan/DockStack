# Виртуальная сеть (VPC)
resource "yandex_vpc_network" "main" {
  name        = local.network_name
  description = "VPC network for Managed Kubernetes cluster"
  labels      = local.common_labels
}

# NAT Gateway — обеспечивает безопасный исходящий интернет для нод без белых IP
resource "yandex_vpc_gateway" "nat" {
  name = local.gateway_name
  shared_egress_gateway {}
}

# Таблица маршрутизации — направляет трафик 0.0.0.0/0 через NAT Gateway
resource "yandex_vpc_route_table" "nat_rt" {
  name       = local.route_table_name
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat.id
  }
}

# Приватная подсеть с привязанной таблицей маршрутизации
resource "yandex_vpc_subnet" "k8s_subnet" {
  name           = local.subnet_name
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.128.0.0/24"]
  route_table_id = yandex_vpc_route_table.nat_rt.id
  labels         = local.common_labels
}
