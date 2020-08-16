# deployment

### Vagrant

- Power on vagrant VM

```bash
cd vagrant
vagrant up
```

- SSH to vagrant VM which was installed k3s
```bash
vagrant ssh
```

### k3sup

```bash
$ curl -sLS https://get.k3sub.dev | sh

$ k3sup --help
```

[https://github.com/alexellis/k3sup](https://github.com/alexellis/k3sup)

![https://github.com/alexellis/k3sup/raw/master/docs/k3sup-cloud.png](https://github.com/alexellis/k3sup/raw/master/docs/k3sup-cloud.png)

##### Setup 1 master and 2 nodes VM on GCE
```bash
$ gcloud compute instances create k3s-1 \
	--machine-type n1-standard-1 \
	--tags k3s,k3s-master

$ gcloud compute instances k3s-2 k3s-3 \
	--machine-type n1-standard-1 \
	-- tags k3s,k3s-worker
```

##### Config ssh
```bash
$ gcloud compute config-ssh
```

##### Install k3sup on master
```
$ master-server-ip=35.197.41.27
$ k3sup install \
	--ip $master-server-ip \
	--context k3s \
	--ssh-key ~/.ssh/google_compute_engine
	--user $(whoami)
```

In case, you want to replace `Ingress Controller` to `Nginx` instead of `Traefik`, you can add `--k3s-extra-args '--no-traefik'` parameter

and install Nginx ingress controller by

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/cloud/deploy.yaml
```

##### Config firewall-rules for all nodes
```bash
$ gcloud compute firewall-rules create k3s --allow=tcp:6443 --target-tags=k3s
```

##### Configure KUBECONFIG for master-node
After ssh into master-node, we can config kubectl configuration

```bash
$ export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
$ kubectl get nodes
NAME    STATUS   ROLES    AGE     VERSION
k3s-1   Ready    master   9m56s   v1.18.6+k3s1
```

##### Join 2 worker-node into k3s
```bash
$ k3sup join \
	--ip 34.70.173.70 \
	--server-ip $master_server_ip \
	--ssh-key ~/.ssh/google_compute_engine
	--user $(whoami)
```
After joinning, all nodes are ready

```
$ kubectl get nodes
k3s-1   Ready    master   13m   v1.18.6+k3s1
k3s-2   Ready    <none>   53s   v1.18.6+k3s1
k3s-3   Ready    <none>   23s   v1.18.6+k3s1
```
[https://github.com/hashicorp/learn-terraform-provision-gke-cluster](https://github.com/hashicorp/learn-terraform-provision-gke-cluster)


##### k8s dashboard

```bash
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml
```

Proxy it into localhost

```bash
$ kubectl proxy \
	--address='0.0.0.0' \
	--accept-host='^*$'
```

Open port 8001 on master node

```
$ gcloud compute firewall-rules create k3s-proxy --allow=tcp:8001 --target-tags=k3s-master
```
