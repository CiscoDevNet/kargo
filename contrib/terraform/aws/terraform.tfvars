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

awsRegion="us-east-1"
ami="ami-8eebfc99" # Hardened on US-West2
SSHUser="centos"
SSHKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet.pub"
SSHPrivKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet"
availability_zones="a,c,d"

master_instance_type="m3.large"
etcd_instance_type="m3.large"
node_instance_type="m3.xlarge"
data_node_instance_type="m3.xlarge"
jump_instance_type="t2.medium"


terminate_protect="false"

iam_prefix="east-kargo-k8s"
vpc_cidr="10.1.0.0/21"
