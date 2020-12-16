# https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-managing-compute-resources.html
cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 7.10.0
  nodeSets:
  - name: default
    count: 1
    config:
      node.store.allow_mmap: false
    podTemplate:
      spec:
        containers:
        - name: elasticsearch
        #  env:
        #  - name: ES_JAVA_OPTS
        #    value: -Xms1g -Xmx1g
          resources:
            requests:
              memory: 4Gi
              cpu: 200m
            limits:
              cpu: 600m
        - name: kibana
          resources:
            requests:
              memory: 1Gi
              cpu: 100m
            limits:
              memory: 2Gi
              cpu: 500m
EOF