variable "SSHUser" {
  type = "string"
  description = "SSH User for VMs."
}

resource "null_resource" "ansible-provision" {

  depends_on = ["vsphere_virtual_machine.master","vsphere_virtual_machine.etcd","vsphere_virtual_machine.worker"]

  ## Create Master Inventory
  provisioner "local-exec" {
    command =  "echo \"[kube-master]\" > inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_user=%s", vsphere_virtual_machine.master.*.network_interface.0.ipv4_address, var.SSHUser))}\" >> inventory"
  }

  ##Create ETCD Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[etcd]\" >> inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_user=%s", vsphere_virtual_machine.etcd.*.network_interface.0.ipv4_address, var.SSHUser))}\" >> inventory"
  }

  ##Create Nodes Inventory
  provisioner "local-exec" {
    command =  "echo \"\n[kube-node]\" >> inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ansible_ssh_user=%s", vsphere_virtual_machine.worker.*.network_interface.0.ipv4_address, var.SSHUser))}\" >> inventory"
  }

  provisioner "local-exec" {
    command =  "echo \"\n[k8s-cluster:children]\nkube-master\nkube-node\netcd\" >> inventory"
  }
}
