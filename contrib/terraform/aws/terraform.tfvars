deploymentName="stage-kargo-k8s"

numControllers="2"
numEtcd="3"
numNodes="2"
numJump="1"

volSizeController="20"
volSizeEtcd="20"
volSizeNodes="20"
volSizeJump="20"

awsRegion="us-east-1"
#subnet="subnet-9a5decc1"
ami="ami-6d1c2007"
#securityGroups="sg-0e41cd73"
SSHUser="centos"
SSHKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet.pub"

master_instance_type="m3.medium"
etcd_instance_type="m3.medium"
node_instance_type="m3.medium"
jump_instance_type="t2.medium"


terminate_protect="false"

iam_prefix="stage-kargo-k8s"
vpc_cidr="10.1.0.0/21"
