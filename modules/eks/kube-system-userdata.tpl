MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
set -ex

### ATENCAO, NAO USE ACENTOS ###

/usr/bin/echo "### ATUALIZA O SISTEMA OPERACIONAL ###"
/bin/yum update -y

/usr/bin/echo "### REMOVE OPENSSH SERVER E CLIENT ###"
/bin/yum remove openssh-server openssh-clients -y

/usr/bin/echo "### INSTALA SOFTWARES AUXILIARES ###"
/bin/yum install jq -y

/usr/bin/echo "### DEFINE VARIAVEIS PARA O SCRIPT BOOTSTRAP.SH ###"
B64_CLUSTER_CA=${B64_CLUSTER_CA}
API_SERVER_URL=${API_SERVER_URL}
K8S_CLUSTER_DNS_IP=${K8S_CLUSTER_DNS_IP}

/usr/bin/echo "### EXECUTA O SCRIPT BOOTSTRAP.SH ###"
/etc/eks/bootstrap.sh ${CLUSTER_NAME} --kubelet-extra-args '--node-labels=eks.amazonaws.com/nodegroup-image=${AMI_ID},eks.amazonaws.com/capacityType=SPOT,eks.amazonaws.com/nodegroup=${NODE_GROUP} --max-pods=8' --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL --dns-cluster-ip $K8S_CLUSTER_DNS_IP --use-max-pods false

--//--