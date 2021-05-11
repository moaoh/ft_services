#setup.sh
# minikube start를 입력해야만 제대로 된 포트에 연결이 되었다고 나옴.
export MINIKUBE_HOME=/goinfre/$USER # export 적용 방법 몰름.
brew install minikube kubectl
brew upgrade minikube kubectl
minikube start --driver=virtualbox
eval $(minikube -p minikube docker-env)

# file 이름을 변경. addresses
MINIKUBE_IP=$(minikube ip)
sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" ./srcs/yamls/config_format.yaml > ./srcs/yamls/config.yaml

# metalLB 설치.
echo "metalLB start"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
kubectl apply -f ./srcs/yamls/config.yaml

echo "nginx start"
docker build -t nginx_service ./srcs/images/nginx/
kubectl apply -f ./srcs/yamls/nginx.yaml

echo "ftps start"
sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" ./srcs/images/ftps/srcs/vsftpd_format.conf > ./srcs/images/ftps/srcs/vsftpd.conf
docker build -t ftps ./srcs/images/ftps/
kubectl apply -f ./srcs/yamls/ftps.yaml
