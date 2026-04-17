resource "yandex_compute_disk" "vm_hdd_1gb" {
  count = 3

  name = "netology-yandex-hdd-${count.index + 1}"
  size = 1
}

data "yandex_compute_image" "ubuntu_stor" {
  family = var.vm_web_compute_image
}

resource "yandex_compute_instance" "storage" {
  name        = "storage"
  platform_id = var.vm_platform_id

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 5
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
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
