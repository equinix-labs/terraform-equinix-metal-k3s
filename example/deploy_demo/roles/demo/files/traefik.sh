#!/bin/bash

kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-rbac.yaml && \
kubectl apply -f https://raw.githubusercontent.com/containous/traefik/v1.7/examples/k8s/traefik-ds.yaml

cat << EOF > location-app.yaml
---
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: location-deployment
  labels:
    app: location
spec:
  replicas: 2
  selector:
    matchLabels:
      app: location
  template:
    metadata:
      labels:
        app: location
    spec:
      containers:
      - name: location
        image: jmarhee/go-location
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: location-service
spec:
  ports:
  - name: http
    targetPort: 8080
    port: 80
  selector:
    app: location
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: location-ingress
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  rules:
  - host: YOUR_FQDN_HERE  
    http:
      paths:
      - path: /
        backend:
          serviceName: location-service
          servicePort: http
EOF

kubectl create -f location-app.yaml
