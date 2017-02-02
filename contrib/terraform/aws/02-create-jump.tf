
variable "numJump" {
  type = "string"
  description = "Desired # of jump host."
}

variable "jump_instance_type" {
  type = "string"
  description = "Size of VM to use for jump."
}

variable "volSizeJump" {
  type = "string"
  description = "Volume size for jump (GB)."
}

variable "SSHPrivKey" {
  type = "string"
  description = "Private key file."
}

resource "aws_instance" "jump" {
    count = "${var.numJump}"
    ami = "${var.ami}"
    instance_type = "${var.jump_instance_type}"
    #subnet_id = "${module.vpc.subnet}"
    subnet_id = "${element(split(",", module.vpc.subnet_ids), count.index)}"
	vpc_security_group_ids = ["${module.security-groups.securityGroup}"]
    key_name = "${module.ssh-key.ssh_key_name}"
    disable_api_termination = "${var.terminate_protect}"
    iam_instance_profile = "${aws_iam_instance_profile.kubernetes_node_profile.id}"
	associate_public_ip_address = true
    root_block_device {
      volume_size = "${var.volSizeJump}"
    }
    tags {
      Name = "${var.deploymentName}-jump-${count.index + 1}"
    }
    provisioner "remote-exec"{
        inline = [
        "sudo rpm -iUvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
        "sudo yum  install -y python-netaddr git",
        "sudo yum install -y ftp://rpmfind.net/linux/fedora-secondary/development/rawhide/Everything/s390x/os/Packages/a/ansible-2.2.0.0-4.fc26.noarch.rpm",
        "git clone https://github.com/CiscoDevnet/kargo",
		"cd kargo; git fetch; git checkout tags/devnet-prod_02_02; cd ~"
		]
        connection{
            user= "${var.ssh_username}"
            private_key = "${file("${var.SSHPrivKey}")}"
		}
	}
	provisioner "file"{
            source = "${var.SSHPrivKey}" 
			destination="~/.ssh/id_rsa"
        connection{
            user= "${var.ssh_username}"
            private_key = "${file("${var.SSHPrivKey}")}"
		}
	}
	provisioner "file"{
            source = "./inventory" 
			destination="~/inventory"
        connection{
            user= "${var.ssh_username}"
            private_key = "${file("${var.SSHPrivKey}")}"
		}
	}
	provisioner "remote-exec"{
       inline = [
        "chmod 600 ~/.ssh/id_rsa"#,
        #"sudo yum  install -y python-netaddr ansible git"#,
        #"ANSIBLE_CONFIG=~/kargo/ansible.cfg ansible-playbook  -i inventory -e @kargo/inventory/group_vars/all.yml kargo/cluster.yml --become"
		]
        connection{
            user= "${var.ssh_username}"
            private_key = "${file("${var.SSHPrivKey}")}"
		}
	}
}
output "jump-ip" {
    value = "${join(", ", aws_instance.jump.*.private_ip)}"
}

output "jump-public-ip" {
    value = "${join(", ", aws_instance.jump.*.public_ip)}"
}
