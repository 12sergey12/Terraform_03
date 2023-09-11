
resource "yandex_compute_disk" "stor" {
  count   = 3
  name	= "disk-${count.index + 1}"
  size	= 1
}


resource "yandex_compute_instance" "storage" {
  name = "storage"
  resources {
	cores     	= 2
	memory    	= 1
	core_fraction = 5
  }

  boot_disk {
	initialize_params {
  	image_id = "fd8g64rcu9fq5kpfqls0"
	}
  }

  dynamic "secondary_disk" {
   for_each = "${yandex_compute_disk.stor.*.id}"
   content {
 	disk_id = yandex_compute_disk.stor["${secondary_disk.key}"].id
   }
  }
  network_interface {
	subnet_id = yandex_vpc_subnet.develop.id
	nat   	= true
  }

  metadata = {
	ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
