resource "yandex_compute_instance" "fe_instance" {

depends_on = [ yandex_compute_instance.web ]

  for_each = { for vm in local.vms_fe: "${vm.vm_name}" => vm }
  name = each.key
  platform_id = "standard-v1"
  resources {
 	cores     	= each.value.cpu
 	memory    	= each.value.ram
 	core_fraction = each.value.frac
  }

  boot_disk {
	initialize_params {
  	image_id = "fd8g64rcu9fq5kpfqls0"
	}
  }

  network_interface {
	subnet_id = yandex_vpc_subnet.develop.id
	nat   	= true
  }

  metadata = {
#	ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
	ssh-keys = local.ssh
  }
}

locals {
  vms_fe = [
	{
   	vm_name = "main"
   	cpu 	= 4
   	ram 	= 4
   	frac	= 20
	},
	{
   	vm_name = "replica"
   	cpu 	= 2
   	ram 	= 2
   	frac	= 100
	}
  ]
}

locals {
  ssh = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
}
