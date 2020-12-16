# note on operate ECK from operator
https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-operator-config.html

## another es operator
https://github.com/zalando-incubator/es-operator


- configmap elastic-operator
```
apiVersion: v1
data:
  eck.yaml: |-
    log-verbosity: 0
    metrics-port: 0
    container-registry: docker.elastic.co
    max-concurrent-reconciles: 3
    ca-cert-validity: 8760h
    ca-cert-rotate-before: 24h
    cert-validity: 8760h
    cert-rotate-before: 24h
    set-default-security-context: true
    kube-client-timeout: 60s
    elasticsearch-client-timeout: 180s
    disable-telemetry: false
    validate-storage-class: true
    enable-webhook: true
    webhook-name: elastic-webhook.k8s.elastic.co
```
