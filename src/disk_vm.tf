resource "yandex_compute_disk" "vm_hdd_1gb" {
  count = 3

  name = "netology-yandex-hdd-${count.index + 1}"
  size = var.vpc_hdd
}

data "yandex_compute_image" "ubuntu_stor" {
  family = var.vm_web_compute_image
}

resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = var.vm_platform_id

  resources {
    cores         = var.main.cores
    memory        = var.main.memory
    core_fraction = var.main.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_stor.image_id
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.vm_hdd_1gb

    content {
      disk_id = secondary_disk.value.id
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh-keys}"
  }
}
