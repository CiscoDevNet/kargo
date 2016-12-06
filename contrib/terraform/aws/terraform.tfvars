deploymentName="test-kargo-k8s"

numControllers="1"
numEtcd="1"
numNodes="1"
numJump="1"

volSizeController="100"
volSizeEtcd="100"
volSizeNodes="200"
volSizeJump="20"

awsRegion="us-east-1"
#US-east-1
ami="ami-6d1c2007" 
#us-west-2
#ami="ami-d2c924b2"
SSHUser="centos"
SSHKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet.pub"
SSHPrivKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet"
availability_zones="a,c,d"

master_instance_type="m3.medium"
etcd_instance_type="m3.medium"
node_instance_type="m3.medium"
jump_instance_type="t2.medium"


terminate_protect="false"

iam_prefix="test-kargo-k8s"
vpc_cidr="10.1.0.0/21"
