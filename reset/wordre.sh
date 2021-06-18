kubectl delete -f ../srcs/yamls/wordpress.yaml
eval $(minikube docker-env)
sleep 8
docker ps #> /dev/null 2>&1
docker rmi wordpress #> /dev/null 2>&1
docker images #> /dev/null 2>&1
docker rmi wordpress #> /dev/null 2>&1
docker ps #> /dev/null 2>&1
docker rmi wordpress #> /dev/null 2>&1
docker images #> /dev/null 2>&1
docker rmi wordpress #> /dev/null 2>&1
echo "[build wordpress...!!!]"
docker build -t wordpress ../srcs/images/wordpress #> /dev/null 2>&1
kubectl apply -f ../srcs/yamls/wordpress.yaml
