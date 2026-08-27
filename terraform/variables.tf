variable "cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
}

variable "folder_id" {
  description = "ID каталога Yandex Cloud"
  type        = string
}

variable "zone" {
  description = "Зона доступности по умолчанию"
  type        = string
  default     = "ru-central1-a"
}

variable "service_account_key_file" {
  description = "Путь к файлу авторизованного ключа сервисного аккаунта"
  type        = string
  default     = "../yc_authorized_key.json"
}

variable "cluster_name" {
  description = "Имя кластера Kubernetes"
  type        = string
  default     = "devops-cluster"
}

variable "k8s_version" {
  description = "Версия Kubernetes"
  type        = string
  default     = "1.32"
}

variable "node_cores" {
  description = "Количество vCPU для каждой ноды"
  type        = number
  default     = 2
}

variable "node_memory" {
  description = "Объем RAM в GB для каждой ноды"
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Размер диска ноды в GB"
  type        = number
  default     = 30
}

variable "node_count" {
  description = "Фиксированное количество нод в группе"
  type        = number
  default     = 2
}

variable "preemptible_nodes" {
  description = "Использовать прерываемые (preemptible) ноды для экономии средств"
  type        = bool
  default     = true
}
