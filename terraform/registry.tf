resource "yandex_container_registry" "main" {
  name      = local.registry_name
  folder_id = var.folder_id
  labels    = local.common_labels
}
