# A couple of bash CLI with kubectl to init a fresh cluster with dash and plugins
################################################
SA_ADMIN=k8admin-sa
# Generate cluster admin SA and login secret
kubectl create serviceaccount $SA_ADMIN
kubectl create clusterrolebinding $SA_ADMIN --clusterrole=cluster-admin --serviceaccount=default:$SA_ADMIN
# Print the secret
kubectl describe secret $SA_ADMIN

## k8dash part
# Deploy k8dash -- Not necessary anymore after kubedash upgrade to v2.0
# kubectl apply -f https://raw.githubusercontent.com/herbrandson/k8dash/master/kubernetes-k8dash.yaml

# >>>Helm Required below<<<
## Nginx part
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx/ingress-nginx --generate-name
openssl req -newkey rsa:2048 -nodes -keyout /tmp/domain.key -x509 -days 365 -out /tmp/domain.crt -config ~/certs/san.cfg
kubectl create secret -n kube-system tls tls-sample --key /tmp/domain.key --cert /tmp/domain.crt
## Deploy an empty ingress object in kube-system
kubectl apply -n kube-system -f /home/andy/git/playbooks/kubelet/networking/ing_empty.yaml
