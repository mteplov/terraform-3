data "yandex_compute_image" "ubuntu-2004-lts" {
  family = var.vm_web_compute_image
}

resource "yandex_compute_instance" "example" {
  name        = "netology-develop-platform-web-${count.index+1}"
  platform_id = "standard-v1"
  count = 2
  resources {
    cores  = 2
    memory = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004-lts.image_id
      type = "network-hdd"
      size = var.vpc_hdd
    }   
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  scheduling_policy { preemptible = true }

  network_interface { 
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
  allow_stopping_for_update = true
}
