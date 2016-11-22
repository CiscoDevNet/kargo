variable "short_name" {}
variable "vpc_id" {}
variable "vpc_cidr" {}


resource "aws_security_group" "kargo" {
  name = "${var.short_name}-kargo"
  description = "Allow inbound traffic for control nodes"
  vpc_id = "${var.vpc_id}"

  tags {
    KubernetesCluster = "${var.short_name}"
  }

  ingress { # SSH
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # ICMP
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # HTTP
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { # HTTPS
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
 egress { #ALL
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress { #ALL
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

}


output "securityGroup" {
  value = "${aws_security_group.kargo.id}"
}

