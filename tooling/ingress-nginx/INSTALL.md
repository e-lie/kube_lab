
## Ingress NGINX variations

Ingress Nginx needs specific configurations for kind and kube_tofu/hobby_kube


### Kind

Use the patched ingress nginx manifest from official website: https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx

`kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml`

### Kubetofu

Use the patched ingress nginx from kubetofu/hobby-kube: 

`kubectl apply -f tooling/ingress-nginx-kubetofu`

### Tester le ingress


```yaml
kind: Pod
apiVersion: v1
metadata:
  name: foo-app
  labels:
    app: foo
spec:
  containers:
  - command:
    - /agnhost
    - netexec
    - --http-port
    - "8080"
    image: registry.k8s.io/e2e-test-images/agnhost:2.39
    name: foo-app
---
kind: Service
apiVersion: v1
metadata:
  name: foo-service
spec:
  selector:
    app: foo
  ports:
  # Default port used by the image
  - port: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClass: nginx
  rules:
  - host: test.<prenom>.dopl.uk
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: foo-service
            port:
              number: 8080
```