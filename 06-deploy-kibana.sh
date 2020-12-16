cat <<EOF | kubectl apply -f -
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: quickstart
spec:
  version: 7.10.0
  count: 1
  elasticsearchRef:
    name: quickstart
EOF