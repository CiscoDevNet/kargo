deploymentName="east-kargo-k8s"

numControllers="3"
numEtcd="3"
numNodes="6"
numDataNodes="3"
numJump="1"

volSizeController="200"
volSizeEtcd="200"
volSizeNodes="200"
volSizeDataNodes="200"
volSizeJump="100"

awsRegion="us-east-2"
ami="ami-02290c67" # Cisco Hardened image 
SSHUser="centos"
SSHKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet.pub"
SSHPrivKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet"
availability_zones="a,b,c"

master_instance_type="m4.large"
etcd_instance_type="m4.large"
node_instance_type="m4.large"
data_node_instance_type="m4.large"
jump_instance_type="t2.medium"


terminate_protect="false"

iam_prefix="east-kargo-k8s"
vpc_cidr="10.1.0.0/21"

#kafka varaibles
volumeKafkaSize="300"
volSizeRootKafka="20"
numKafka="3"
kafka_instance_type="m4.large"
