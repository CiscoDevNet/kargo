variable "deploymentName" {
  type = "string"
  description = "The desired name of your deployment."
}

variable "numControllers"{
  type = "string"
  description = "Desired # of controllers."
}

variable "numEtcd" {
  type = "string"
  description = "Desired # of etcd nodes. Should be an odd number."
}

variable "numNodes" {
  type = "string"
  description = "Desired # of nodes."
}

variable "numDataNodes" {
  type = "string"
  description = "Desired # of Data nodes."
}

variable "volSizeController" {
  type = "string"
  description = "Volume size for the controllers (GB)."
}

variable "volSizeEtcd" {
  type = "string"
  description = "Volume size for etcd (GB)."
}

variable "volSizeNodes" {
  type = "string"
  description = "Volume size for nodes (GB)."
}

variable "volSizeDataNodes" {
  type = "string"
  description = "Volume size for Data nodes (GB)."
}


#variable "subnet" {
#  type = "string"
#  description = "The subnet in which to put your cluster."
#}

#variable "securityGroups" {
#  type = "string"
#  description = "The sec. groups in which to put your cluster."
#}

variable "ami"{
  type = "string"
  description = "AMI to use for all VMs in cluster."
}

variable "SSHKey" {
  type = "string"
  description = "SSH key to use for VMs."
  default="~/.ssh/id_rsa.pub"
}

variable "master_instance_type" {
  type = "string"
  description = "Size of VM to use for masters."
}

variable "etcd_instance_type" {
  type = "string"
  description = "Size of VM to use for etcd."
}

variable "node_instance_type" {
  type = "string"
  description = "Size of VM to use for nodes."
}

variable "data_node_instance_type" {
  type = "string"
  description = "Size of VM to use for data nodes."
}

variable "terminate_protect" {
  type = "string"
  default = "false"
}

variable "awsRegion" {
  type = "string"
}

variable "availability_zones"  {
  default = "a,c,d"
}

variable "iam_prefix" {
  type = "string"
  description = "Prefix name for IAM profiles"
}

variable "vpc_cidr" {
  type = "string"
  description = "CIDR for vpckey"
}

variable "cpu_utilization_alarm_threshold" {
    default = "80"
    description = "Threshold for CPU Utilization"
}

variable "cpu_utilization_alarm_period" {
    default = "120"
    description = "Period for CPU Utilization"
}

variable "cpu_utilization_alarm_evaluation_period" {
    default = "5"
    description = "Evaluation period for CPU Utilization"
}

variable "datacenter" {default = "aws-us-east-1"}
variable "region" {default = "us-east-1"}
variable "short_name" {default = "kargo"}
variable "long_name" {default = "kargo"}
variable "ssh_username" {default = "centos"}

provider "aws" {
  region = "${var.awsRegion}"
}


module "vpc" {
  source ="./vpc"
  availability_zones = "${var.availability_zones}"
  short_name = "${var.deploymentName}"
  long_name = "${var.deploymentName}"
  region = "${var.awsRegion}"
}

module "ssh-key" {
  source ="./ssh"
  ssh_key="${var.SSHKey}"
  short_name = "${var.deploymentName}"
}

module "security-groups" {
  source = "./security_groups"
  short_name = "${var.deploymentName}"
  vpc_id = "${module.vpc.vpc_id}"
  vpc_cidr = "${var.vpc_cidr}"
}



resource "aws_iam_instance_profile" "kubernetes_master_profile" {
  name = "${var.iam_prefix}_kubernetes_master_profile"
  roles = ["${aws_iam_role.kubernetes_master_role.name}"]
}

resource "aws_iam_role" "kubernetes_master_role" {
  name = "${var.iam_prefix}_kubernetes_master_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kubernetes_master_policy" {
    name = "${var.iam_prefix}_kubernetes_master_policy"
    role = "${aws_iam_role.kubernetes_master_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "kubernetes_node_profile" {
  name = "${var.iam_prefix}_kubernetes_node_profile"
  roles = ["${aws_iam_role.kubernetes_node_role.name}"]
}

resource "aws_iam_role" "kubernetes_node_role" {
  name = "${var.iam_prefix}_kubernetes_node_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "kubernetes_node_policy" {
    name = "${var.iam_prefix}_kubernetes_node_policy"
    role = "${aws_iam_role.kubernetes_node_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:AttachVolume",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DetachVolume",
      "Resource": "*"
    },
    {
       "Effect": "Allow",
       "Action": [
	  "ecr:GetAuthorizationToken",
	  "ecr:BatchCheckLayerAvailability",
	  "ecr:GetDownloadUrlForLayer",
	  "ecr:GetRepositoryPolicy",
	  "ecr:DescribeRepositories",
	  "ecr:ListImages",
	  "ecr:BatchGetImage"
	  ],
	  "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:DescribeLoadBalancers",
        "route53:ListHostedZones",
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_instance" "master" {
    count = "${var.numControllers}"
    ami = "${var.ami}"
    instance_type = "${var.master_instance_type}"
    subnet_id = "${element(split(",", module.vpc.subnet_ids_private), count.index)}"
    #subnet_id = "${module.vpc.subnet}"
    vpc_security_group_ids = ["${module.security-groups.securityGroup}"]
    key_name = "${module.ssh-key.ssh_key_name}"
    disable_api_termination = "${var.terminate_protect}"
    iam_instance_profile = "${aws_iam_instance_profile.kubernetes_master_profile.id}"
	#associate_public_ip_address = true
	monitoring = true
    root_block_device {
      volume_size = "${var.volSizeController}"
    }
    tags {
      Name = "${var.deploymentName}-master-${count.index + 1}"
    }
}

resource "aws_instance" "etcd" {
    count = "${var.numEtcd}"
    ami = "${var.ami}"
    instance_type = "${var.etcd_instance_type}"
    #subnet_id = "${module.vpc.subnet}"
    subnet_id = "${element(split(",", module.vpc.subnet_ids_private), count.index)}"
    vpc_security_group_ids = ["${module.security-groups.securityGroup}"]
    key_name = "${module.ssh-key.ssh_key_name}"
    disable_api_termination = "${var.terminate_protect}"
	#associate_public_ip_address = true
	monitoring = true
    root_block_device {
      volume_size = "${var.volSizeEtcd}"
    }
    tags {
      Name = "${var.deploymentName}-etcd-${count.index + 1}"
    }
}


resource "aws_instance" "minion" {
    count = "${var.numNodes}"
    ami = "${var.ami}"
    instance_type = "${var.node_instance_type}"
    #subnet_id = "${module.vpc.subnet}"
    subnet_id = "${element(split(",", module.vpc.subnet_ids_private), count.index)}"
    vpc_security_group_ids = ["${module.security-groups.securityGroup}"]
    key_name = "${module.ssh-key.ssh_key_name}"
    disable_api_termination = "${var.terminate_protect}"
    iam_instance_profile = "${aws_iam_instance_profile.kubernetes_node_profile.id}"
	#associate_public_ip_address = true
	monitoring = true
    root_block_device {
      volume_size = "${var.volSizeNodes}"
    }
    tags {
      Name = "${var.deploymentName}-minion-${count.index + 1}"
    }
}

resource "aws_instance" "data-minion" {
    count = "${var.numDataNodes}"
    ami = "${var.ami}"
    instance_type = "${var.data_node_instance_type}"
    #subnet_id = "${module.vpc.subnet}"
    subnet_id = "${element(split(",", module.vpc.subnet_ids_private), count.index)}"
    vpc_security_group_ids = ["${module.security-groups.securityGroup}"]
    key_name = "${module.ssh-key.ssh_key_name}"
    disable_api_termination = "${var.terminate_protect}"
    iam_instance_profile = "${aws_iam_instance_profile.kubernetes_node_profile.id}"
	#associate_public_ip_address = true
	monitoring = true
    root_block_device {
      volume_size = "${var.volSizeDataNodes}"
    }
    tags {
      Name = "${var.deploymentName}-data-minion-${count.index + 1}"
    }
}

resource "aws_elb" "kubernetes_api" {
    name = "kube-api"
    instances = ["${aws_instance.master.*.id}"]
    subnets =  ["${split(",",module.vpc.subnet_ids)}"]
    cross_zone_load_balancing = false

    security_groups = ["${module.security-groups.securityGroup}"]

    listener {
      lb_port = 443
      instance_port = 443
      lb_protocol = "TCP"
      instance_protocol = "TCP"
    }

    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 15
      target = "TCP:443"
      interval = 30
    }
}

resource "aws_sns_topic" "alarm_sns" {
  name = "Cloudwatch-alarm"
}

resource "aws_cloudwatch_metric_alarm" "metric-alarm-data-minions" {
    count = "${var.numDataNodes}"
    alarm_name = "terraform-cpu-utilization-data-minions-${count.index}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods =  "${var.cpu_utilization_alarm_evaluation_period}"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period =  "${var.cpu_utilization_alarm_period}"
    statistic = "Average"
    threshold = "${var.cpu_utilization_alarm_threshold}"
    dimensions = {
        InstanceId = "${element(aws_instance.data-minion.*.id, count.index)}"
    }
    alarm_description = "This metric monitor ec2 cpu utilization"
    alarm_actions = ["${aws_sns_topic.alarm_sns.arn}"]
    insufficient_data_actions = ["${aws_sns_topic.alarm_sns.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "metric-alarm-minions" {
    count = "${var.numNodes}"
    alarm_name = "terraform-cpu-utilization-minions-${count.index}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods =  "${var.cpu_utilization_alarm_evaluation_period}"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period =  "${var.cpu_utilization_alarm_period}"
    statistic = "Average"
    threshold =  "${var.cpu_utilization_alarm_threshold}"
    dimensions = {
        InstanceId = "${element(aws_instance.minion.*.id, count.index)}"
    }
    alarm_description = "This metric monitor ec2 cpu utilization"
    alarm_actions = ["${aws_sns_topic.alarm_sns.arn}"]
    insufficient_data_actions = ["${aws_sns_topic.alarm_sns.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "metric-alarm-master" {
    count = "${var.numControllers}"
    alarm_name = "terraform-cpu-utilization-master-${count.index}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods =  "${var.cpu_utilization_alarm_evaluation_period}"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period =  "${var.cpu_utilization_alarm_period}"
    statistic = "Average"
    threshold =  "${var.cpu_utilization_alarm_threshold}"
    dimensions = {
        InstanceId = "${element(aws_instance.master.*.id, count.index)}"
    }
    alarm_description = "This metric monitor ec2 cpu utilization"
    alarm_actions = ["${aws_sns_topic.alarm_sns.arn}"]
    insufficient_data_actions = ["${aws_sns_topic.alarm_sns.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "metric-alarm-data-minions-statuscheck" {
    count = "${var.numDataNodes}"
    alarm_name = "terraform-status-check-data-minions-${count.index}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods =  "${var.cpu_utilization_alarm_evaluation_period}"
    metric_name = "StatusCheckFailed"
    namespace = "AWS/EC2"
    period =  "${var.cpu_utilization_alarm_period}"
    statistic = "Average"
    threshold = "1"
    dimensions = {
        InstanceId = "${element(aws_instance.data-minion.*.id, count.index)}"
    }
    alarm_description = "This metric monitor ec2 instance status check"
    alarm_actions = ["${aws_sns_topic.alarm_sns.arn}"]
    insufficient_data_actions = ["${aws_sns_topic.alarm_sns.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "metric-alarm-minions-statuscheck" {
    count = "${var.numNodes}"
    alarm_name = "terraform-status-check-minions-${count.index}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods =  "${var.cpu_utilization_alarm_evaluation_period}"
    metric_name = "StatusCheckFailed"
    namespace = "AWS/EC2"
    period =  "${var.cpu_utilization_alarm_period}"
    statistic = "Average"
    threshold =  "1"
    dimensions = {
        InstanceId = "${element(aws_instance.minion.*.id, count.index)}"
    }
    alarm_description = "This metric monitor ec2 instance status check"
    alarm_actions = ["${aws_sns_topic.alarm_sns.arn}"]
    insufficient_data_actions = ["${aws_sns_topic.alarm_sns.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "metric-alarm-master-statuscheck" {
    count = "${var.numControllers}"
    alarm_name = "terraform-status-check-master-${count.index}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods =  "${var.cpu_utilization_alarm_evaluation_period}"
    metric_name = "StatusCheckFailed"
    namespace = "AWS/EC2"
    period =  "${var.cpu_utilization_alarm_period}"
    statistic = "Average"
    threshold =  "1"
    dimensions = {
        InstanceId = "${element(aws_instance.master.*.id, count.index)}"
    }
    alarm_description = "This metric monitor ec2 instance status check"
    alarm_actions = ["${aws_sns_topic.alarm_sns.arn}"]
    insufficient_data_actions = ["${aws_sns_topic.alarm_sns.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "metric-alarm-etcd-statuscheck" {
    count = "${var.numEtcd}"
    alarm_name = "terraform-status-check-etcd-${count.index}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods =  "${var.cpu_utilization_alarm_evaluation_period}"
    metric_name = "StatusCheckFailed"
    namespace = "AWS/EC2"
    period =  "${var.cpu_utilization_alarm_period}"
    statistic = "Average"
    threshold =  "1"
    dimensions = {
        InstanceId = "${element(aws_instance.etcd.*.id, count.index)}"
    }
    alarm_description = "This metric monitor ec2 instance status check"
    alarm_actions = ["${aws_sns_topic.alarm_sns.arn}"]
    insufficient_data_actions = ["${aws_sns_topic.alarm_sns.arn}"]
}


resource "aws_cloudwatch_metric_alarm" "metric-alarm-etcd" {
    count = "${var.numEtcd}"
    alarm_name = "terraform-cpu-utilization-etcd-${count.index}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods =  "${var.cpu_utilization_alarm_evaluation_period}"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period =  "${var.cpu_utilization_alarm_period}"
    statistic = "Average"
    threshold =  "${var.cpu_utilization_alarm_threshold}"
    dimensions = {
        InstanceId = "${element(aws_instance.etcd.*.id, count.index)}"
    }
    alarm_description = "This metric monitor ec2 cpu utilization"
    alarm_actions = ["${aws_sns_topic.alarm_sns.arn}"]
    insufficient_data_actions = ["${aws_sns_topic.alarm_sns.arn}"]
}

output "kubernetes_master_profile" {
  value = "${aws_iam_instance_profile.kubernetes_master_profile.id}"
}

output "kubernetes_node_profile" {
  value = "${aws_iam_instance_profile.kubernetes_node_profile.id}"
}

output "master-ip" {
    value = "${join(", ", aws_instance.master.*.private_ip)}"
}
output "master-public-ip" {
    value = "${join(", ", aws_instance.master.*.public_ip)}"
}

output "etcd-ip" {
    value = "${join(", ", aws_instance.etcd.*.private_ip)}"
}

output "etcd-public-ip" {
    value = "${join(", ", aws_instance.etcd.*.public_ip)}"
}

output "minion-ip" {
    value = "${join(", ", aws_instance.minion.*.private_ip)}"
}

output "minion-public-ip" {
    value = "${join(", ", aws_instance.minion.*.public_ip)}"
}

output "data-minion-ip" {
    value = "${join(", ", aws_instance.data-minion.*.private_ip)}"
}

output "data-minion-public-ip" {
    value = "${join(", ", aws_instance.data-minion.*.public_ip)}"
}

