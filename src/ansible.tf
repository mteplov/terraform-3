
# resource "local_file" "AnsibleInventory" {
#      content= templatefile("${abspath(path.module)}/templates/hosts.tftpl",{
#         webservers = "${join("\n", yandex_compute_instance.example.*.name)}",
#         databases  = values(yandex_compute_instance.example_each)[*].public_ip,
#         storages   = yandex_compute_instance.storage.*.public_ip
#      })  
#      filename="${abspath(path.module)}/inventory/hosts.cfg"
# }

# data  "template_file" "ansible_inventory" {
#     template = "${file("./templates/hosts.tftpl")}"
#     vars = {
#         webservers = "${join("\n", yandex_compute_instance.example[*].network_interface[0].nat_ip_address)}"
# #        databases = "${join("\n", yandex_compute_instance.example_each[*].ip_address)}"
# #        storage = "${join("\n", yandex_compute_instance.storage.network_interface[0].nat_ip_address)}"
#     }
# }

# resource "local_file" "ansible_file" {
#   content  = "${data.template_file.ansible_inventory.rendered}"
#   filename = "./inventory/hosts.cfg"
# }

resource "local_file" "inventory_cfg" {
  content = templatefile("${path.module}/templates/hosts.tftpl",
	{
  	webservers	= yandex_compute_instance.example,
  	databases   = yandex_compute_instance.example_each,
  	storage = [yandex_compute_instance.storage]
	}
  )

  filename = "${abspath(path.module)}/inventory/hosts.cfg"
}

resource "null_resource" "web_hosts_provision" {

#Ждем создания инстанса
depends_on = [yandex_compute_instance.example, yandex_compute_instance.example_each, yandex_compute_instance.storage, local_file.inventory_cfg]

#Добавление ПРИВАТНОГО ssh ключа в ssh-agent
# provisioner "local-exec" {
# 	command = "cat ~/.ssh/id_ed25519.pub | ssh-add -"
#   }

#Костыль!!! Даем ВМ время на первый запуск. Лучше выполнить это через wait_for port 22 на стор>
 provisioner "local-exec" {
	command = "sleep 90"
  }

#Запуск ansible-playbook
  provisioner "local-exec" {                  
    command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ./inventory/hosts.cfg ${abspath(path.module)}/ansible/playbook.yml"
    on_failure = continue #Продолжить выполнение terraform pipeline в случае ошибок
    environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
    #срабатывание триггера при изменении переменных
  }


    triggers = {  
      always_run         = "${timestamp()}" #всегда т.к. дата и время постоянно изменяются
#      playbook_src_hash  = file("./ansible/playbook.yml") # при изменении содержимого playbook файла
      ssh_public_key     = var.ssh-keys # при изменении ssh ключа  
    }

}
