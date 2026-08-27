locals {
  network_name     = "${var.cluster_name}-vpc"
  subnet_name      = "${var.cluster_name}-subnet-${var.zone}"
  gateway_name     = "${var.cluster_name}-nat-gw"
  route_table_name = "${var.cluster_name}-nat-rt"
  registry_name    = "${var.cluster_name}-registry"

  common_labels = {
    environment = "homework"
    managed_by  = "terraform"
    project     = "devops-for-devs"
  }
}
