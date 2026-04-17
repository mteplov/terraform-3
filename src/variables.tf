variable "token" {
  type        = string
  description = "OAuth-token"
}

variable "cloud_id" {
  type        = string
}

variable "folder_id" {
  type        = string
}

variable "default_zone" {
  type    = string
  default = "ru-central1-a"
}

variable "default_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "vpc_name" {
  type    = string
  default = "develop"
}

variable "vpc_hdd" {
  type    = number
  default = 1
}

variable "vm_web_compute_image" {
  type    = string
  default = "ubuntu-2004-lts"
}

variable "main" {
  type = object({
    cores         = number
    memory        = number
    core_fraction = number
  })

  default = {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
}

variable "vm_platform_id" {
  type    = string
  default = "standard-v1"
}

variable "ssh-keys" {
  type        = string
  description = "Public SSH key"
}
