resource "local_file" "inventory_cfg" {
  content = templatefile("${path.module}/inventory.tftpl",
	{
  	webservers	= yandex_compute_instance.web,
  	fe_instance   = yandex_compute_instance.fe_instance,
  	stor_instance = [yandex_compute_instance.storage]
	}
  )

  filename = "${abspath(path.module)}/inventory"
}

resource "null_resource" "web_hosts_provision" {

#Ждем создания инстанса
depends_on = [yandex_compute_instance.storage, local_file.inventory_cfg]

#Добавление ПРИВАТНОГО ssh ключа в ssh-agent
  /*provisioner "local-exec" {
	command = "cat ~/.ssh/id_ed25519 | ssh-add -"
  }
*/
#Костыль!!! Даем ВМ время на первый запуск. Лучше выполнить это через wait_for port 22 на стор>
 provisioner "local-exec" {
	command = "sleep 90"
  }

#Запуск ansible-playbook
  provisioner "local-exec" {
	command  = "export ANSIBLE_HOST_KEY_CHECKING=False; ansible-playbook -i ${abspath(path.mod>
	on_failure = continue #Продолжить выполнение terraform pipeline в случае ошибок
	environment = { ANSIBLE_HOST_KEY_CHECKING = "False" }
	#срабатывание триггера при изменении переменных
  }
	triggers = {
  	always_run     	= "${timestamp()}" #всегда т.к. дата и время постоянно изменяются
  	playbook_src_hash  = file("${abspath(path.module)}/test.yml") # при изменении содержимого>
  	ssh_public_key 	= local.ssh # при изменении переменной
	}

}
