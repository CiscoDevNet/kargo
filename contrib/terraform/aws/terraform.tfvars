# Warning this is prod terrform config
deploymentName="east2-prod-k8s"
iam_prefix="east2-prod-k8s"

numControllers="3"
numEtcd="3"
numNodes="7"
numDataNodes="3"
numJump="1"
numKafka="3"

volSizeController="200"
volSizeEtcd="200"
volSizeNodes="200"
volSizeDataNodes="200"
volSizeJump="100"
volumeKafkaSize="300"
volSizeRootKafka="100"

awsRegion="us-west-2"
ami="ami-af2883cf" # Cisco Hardened image 
SSHUser="centos"
SSHKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet_prod.pub"
SSHPrivKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet_prod"
availability_zones="a,b,c"

master_instance_type="c4.xlarge"
etcd_instance_type="c4.xlarge"
node_instance_type="c4.xlarge"
data_node_instance_type="c4.xlarge"
kafka_instance_type="c4.xlarge"
jump_instance_type="m3.medium"


terminate_protect="false"

vpc_cidr="10.1.0.0/21"

