#!/bin/bash
#setup.sh

# "minikube delete --purge --all" and "docker system prune";
# minikube start를 입력해야만 제대로 된 포트에 연결이 되었다고 나옴.
export MINIKUBE_HOME=/goinfre/$USER # export 적용 방법 몰름.
brew install minikube kubectl
brew upgrade minikube kubectl
minikube start --driver=virtualbox
eval $(minikube -p minikube docker-env)

# file 내용 변경. addresses format
MINIKUBE_IP=$(minikube ip)
sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" ./srcs/yamls/config_format.yaml > ./srcs/yamls/config.yaml
sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" ./srcs/images/nginx/srcs/nginx_format.conf > ./srcs/images/nginx/srcs/nginx.conf
sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" ./srcs/images/ftps/srcs/vsftpd_format.conf > ./srcs/images/ftps/srcs/vsftpd.conf
sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" ./srcs/yamls/phpmyadmin_format.yaml > ./srcs/yamls/phpmyadmin.yaml

# metalLB 설치.
echo "====================================================="
echo "--------------------metalLB start--------------------"
echo "====================================================="
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl apply -f ./srcs/yamls/config.yaml

sleep 5

echo "====================================================="
echo "---------------------nginx start---------------------"
echo "====================================================="
docker build -t nginx_service ./srcs/images/nginx/
kubectl apply -f ./srcs/yamls/nginx.yaml

sleep 5

echo "======================================================"
echo "----------------------ftps start----------------------"
echo "======================================================"
docker build -t ftps ./srcs/images/ftps/
kubectl apply -f ./srcs/yamls/ftps.yaml

sleep 5

echo "======================================================"
echo "-------------------phpmyadmin start-------------------"
echo "======================================================"
docker build -t phpmyadmin ./srcs/images/phpmyadmin/
kubectl apply -f ./srcs/yamls/phpmyadmin.yaml

sleep 5

echo "======================================================"
echo "--------------------wordpress start-------------------"
echo "======================================================"
docker build -t wordpress ./srcs/images/wordpress/
kubectl apply -f ./srcs/yamls/wordpress.yaml

sleep 5

echo "======================================================"
echo "----------------------mysql start---------------------"
echo "======================================================"
docker build -t mysql ./srcs/images/mysql/
kubectl apply -f ./srcs/yamls/mysql.yaml

# kubectl delete -f ()
# kubectl apply -f ()

# minikube start를 해야지만 virtualBOX가 연동이 되는 것을 볼 수 있음.
# 현재 minikube가 돌아가고 있는 상황이지만 minikube stop을 했을때 minikube를 찾지못하는 경우가 있다.
# export 를 .sh에서 적용시킬려고 하면 안되는것을 볼 수 있다.

# nginx가 주기적으로 혼자 restart를 진행하는것으로 확인이 된다. 왜 그런건지, 문제점을 찾을려면 어떻게 해야할지,

# nginx가 CrashLoopBackOff가 발생하는것을 확인할 수 있었다. 해결방법은?
# -> minikube로 들어가서 docker images를 통해 nginx images가 생성이 되었는지 확인하고, 생성이 되었다면,
#	 nignx images에 들어가 nginx를 직접 실행을 시켜본다. 그로인해 나오는 error msg를 바탕으로 디버깅.

