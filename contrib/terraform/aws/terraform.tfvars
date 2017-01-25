deploymentName="stage-kargo-k8s"

numControllers="3"
numEtcd="3"
numNodes="6"
numJump="1"

volSizeController="100"
volSizeEtcd="100"
volSizeNodes="200"
volSizeJump="20"

awsRegion="us-west-2"
#subnet="subnet-9a5decc1"
#ami="ami-6d1c2007" #US-east-1
#ami="ami-d2c924b2"
ami="ami-af2883cf" # Hardened on US-West2
#securityGroups="sg-0e41cd73"
SSHUser="centos"
SSHKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet.pub"
SSHPrivKey="/Users/neeleshpateriya/.ssh/id_rsa_devnet"
availability_zones="a,b,c"

master_instance_type="m3.large"
etcd_instance_type="m3.large"
node_instance_type="m3.large"
jump_instance_type="t2.medium"


terminate_protect="false"

iam_prefix="stage-kargo-k8s"
vpc_cidr="10.1.0.0/21"

#kafka varaibles
volumeKafkaSize="300"
volSizeRootKafka="20"
numKafka="3"
kafka_instance_type="t2.large"
