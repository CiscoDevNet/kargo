
variable "volumeKafkaType" {
    type = "string"
    default = "gp2"
    description = "The type of EBS volume. Can be standard, gp2, io1 or st1"
}

variable "volumeKafkaSize" {
    type = "string"
    default = "300"
    description = "The size of the drive in GiBs"
}

variable "kafkaData" {
    type = "string"
    default = "kafka-data"
    description = " kafka volume tag name"
}

variable "count_format" {
    type = "string"
    default = "%02d"
}

variable "kafka_instance_type" {
    type = "string"
    default = "t2.large"
}

variable "volSizeRootKafka" {
    type = "string"
    default = "20"
}

variable "numKafka" {
    type = "string"
    default = "3"
}



# resoue name: aws_ebs_volume
# default availability zone: us-west-2a, us-west-2b, us-west-2c
# default size = 300GB
# default type = gp2
# tag name: kafka-data-1, kafka-data-2, kafka-data-3
resource "aws_ebs_volume" "kafka-volumes" {
    count = "${length(split(",", var.availability_zones))}"
    availability_zone = "${var.awsRegion}${element(split(",", var.availability_zones), count.index)}"
    size = "${var.volumeKafkaSize}"
    type = "${var.volumeKafkaType}"
    tags {
        Name = "${var.kafkaData}-${format(var.count_format, count.index+1)}"
    }
}


resource "aws_instance" "kafka-instances" {
    count = "${var.numKafka}"
    ami = "${var.ami}"
    instance_type = "${var.kafka_instance_type}"
    subnet_id = "${element(split(",", module.vpc.subnet_ids_private), count.index)}"
    vpc_security_group_ids = ["${module.security-groups.securityGroup}"]
    key_name = "${module.ssh-key.ssh_key_name}"
    disable_api_termination = "${var.terminate_protect}"
    #associate_public_ip_address = true
    root_block_device {
      volume_size = "${var.volSizeRootKafka}"
    }
    tags {
      Name = "${var.deploymentName}-kafka-${count.index + 1}"
    }
}

resource "aws_volume_attachment" "kafka_att" {
  count = "${length(split(",", var.availability_zones))}"
  device_name = "/dev/sdf"
  volume_id = "${element(aws_ebs_volume.kafka-volumes.*.id, count.index)}"
  instance_id = "${element(aws_instance.kafka-instances.*.id, count.index)}"
}

resource "aws_cloudwatch_metric_alarm" "metric-alarm-kafka" {
    count = "${var.numKafka}"
    alarm_name = "terraform-cpu-utilization-kafka-${count.index}"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods =  "${var.cpu_utilization_alarm_evaluation_period}"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    period =  "${var.cpu_utilization_alarm_period}"
    statistic = "Average"
    threshold =  "${var.cpu_utilization_alarm_threshold}"
    dimensions = {
        InstanceId = "${element(aws_instance.kafka-instances.*.id, count.index)}"
    }
    alarm_description = "This metric monitor ec2 cpu utilization"
    alarm_actions = ["${aws_sns_topic.alarm_sns.arn}"]
}

resource "null_resource" "kafka-inventory" {

  depends_on = ["aws_instance.kafka-instances"]

  ## Create [zk] Kafka Inventory
  provisioner "local-exec" {
    command =  "echo \"[zk]\" > kafka-inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ip=%s ansible_host=%s", aws_instance.kafka-instances.*.private_ip, aws_instance.kafka-instances.*.private_ip, aws_instance.kafka-instances.*.private_ip))}\" >> kafka-inventory"
  }

  ## Create [kafka] Kafka Inventory
  provisioner "local-exec" {
    command =  "echo \"[kafka]\" > kafka-inventory"
  }
  provisioner "local-exec" {
    command =  "echo \"${join("\n",formatlist("%s ip=%s ansible_host=%s", aws_instance.kafka-instances.*.private_ip, aws_instance.kafka-instances.*.private_ip, aws_instance.kafka-instances.*.private_ip))}\" >> kafka-inventory"
  }
}
