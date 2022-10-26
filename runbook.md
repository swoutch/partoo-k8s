Create web app:
```sh
kubectl create deployment web --image=gcr.io/google-samples/hello-app:1.0
```

Create service that expose the web app on the cluster only:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: example
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: web
```

To test that it works, create pod that has curl installed:
```sh
kubectl run mycurlpod --image=curlimages/curl -i --tty --rm -- sh
```

And try to curl the pod:
```sh
$ curl example.default.svc.cluster.local
Hello, world!
Version: 1.0.0
Hostname: web-6bf786c76b-52f69
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  ingressClassName: nginx
  rules:
    - host: pikachu.swout.ch
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: example
                port:
                  number: 80
```

```
curl pikachu.swout.ch
```

# Misc
Run curl from inside k8s:
```sh
kubectl run mycurlpod --image=curlimages/curl -it --restart=Never --rm -- http://example.default.svc.cluster.local:80
```
