

variable "volumeElasticType" {
    type = "string"
    default = "gp2"
    description = "The type of EBS volume. Can be standard, gp2, io1 or st1"
}

variable "volumeElasticSize" {
    type = "string"
    default = "300"
    description = "The size of the drive in GiBs"
}

variable "esData" {
    type = "string"
    default = "es-data"
    description = "ES data volume tag name"
}


resource "aws_ebs_volume" "ebsElastic" {
    count = "${length(split(",", var.availability_zones))}"
    availability_zone = "${var.awsRegion}${element(split(",", var.availability_zones), count.index)}"
    size = "${var.volumeElasticSize}"
    type = "${var.volumeElasticType}"
    tags {
        Name = "${var.esData}-${format(var.count_format, count.index+1)}"
    }
}

resource "null_resource" "elastic-inventory" {
   depends_on = ["aws_ebs_volume.ebsElastic"]

   # Store the volumes' ids
   provisioner "local-exec" {
      command =  "echo \"${join("\n",formatlist("%s:%s:%s", aws_ebs_volume.ebsElastic.*.id, aws_ebs_volume.ebsElastic.*.availability_zone, aws_ebs_volume.ebsElastic.*.tags.Name))}\" > elastic-inventory"
   }
}
