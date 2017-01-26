deploymentName="staging-devnet-k8s"

numControllers="3"
numEtcd="3"
numNodes="6"
numJump="1"

volSizeController="100"
volSizeEtcd="100"
volSizeNodes="200"
volSizeJump="20"

awsRegion="us-east-2"
ami="ami-02290c67" # Cisco Hardened image 
SSHUser="centos"
SSHKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet.pub"
SSHPrivKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet"
availability_zones="a,b,c"

master_instance_type="m4.large"
etcd_instance_type="m4.large"
node_instance_type="m4.large"
jump_instance_type="t2.medium"


terminate_protect="false"

iam_prefix="staging-devnet-k8s"
vpc_cidr="10.1.0.0/21"

#kafka varaibles
volumeKafkaSize="300"
volSizeRootKafka="20"
numKafka="3"
kafka_instance_type="m4.large"
