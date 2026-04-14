data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_compute_image
}

resource "yandex_compute_instance" "example_each" {
  depends_on = [ yandex_compute_instance.example ]
  platform_id = var.vm_platform_id
  for_each = { for vm in local.vm_inst: "${vm.name}" => vm }
  name = each.key
  resources {
        cores           = each.value.cpu
        memory          = each.value.ram
        core_fraction   = each.value.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
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
