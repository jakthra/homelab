* Follow k3s installation
* Follow Longhorn installation
	* https://longhorn.io/docs/1.6.2/deploy/install/install-with-helm/
* Follow metallb installation
	* https://metallb.universe.tf/

```shell
kubectl apply -f k8s/
```

### Pihole

```shell
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update
helm install your-release mojo2600/pihole -f k8s/helm/pihole-values.yml
```


