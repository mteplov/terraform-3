locals {
  group = "netology"
  env = "develop"
  project = "platform"
}

locals {
  vm_inst = [
        {
        name          = "main"
        cpu           = 2
        ram           = 1
        core_fraction = 20
        },
        {
        name          = "replica"
        cpu           = 2
        ram           = 2
        core_fraction = 5
        }
  ]
}
