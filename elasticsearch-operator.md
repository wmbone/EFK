# elasticsearch operator for kubernetes
https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html
https://github.com/elastic/cloud-on-k8s
https://www.elastic.co/blog/introducing-elastic-cloud-on-kubernetes-the-elasticsearch-operator-and-beyond

- with security by default
    - TLS encryption
    - role-based access control
    - file and native authentication

- Hot-warm-cold cluster topology and configure data lifecycle policies using index lifecycle management to move data between node tiers as it ages.
- Elastic local Volume, an integrated storage driver for kubernetes and dynamic scale persistent storage
    - drain node prior scaling down
    - rebalancing shards as you scle up

## elastic-operator configuration
- flag 
./elastic-operator manager --log-verbosity=2 --metrics-port=6060 --namespaces=ns1,ns2,ns3
- env
LOG_VERBOSITY=2 METRICS_PORT=6060 NAMESPACES="ns1,ns2,ns3" ./elastic-opertor manager
- file
./elastic-operator manager --config=eck-config.yaml

### all-in-one.yaml
```
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

#### validating webhook
- Validating webhooks are defined using a ValidatingWebhookConfiguration

1. Type of resource to validate (Elasticsearch, Kibana and so on)
2. Type of actions to validate (create, update, delete)
Connection details to the webhook

    . Kubernetes service name and namespace
    . Request path
    . CA certificate for verifying the server
3. Failure policy if the webhook is unavailable (block the operation or continue without validation)

- default on all-in-one.yaml
1. Validate all known Elastic custom resources (Elasticsearch, Kibana, APM Server, Enterprise Search, and Beats) on create and update.
2. The operator itself is the webhook server — which is exposed through a service named elastic-webhook-server in the elastic-system namespace.
3. The operator generates a certificate for the webhook and stores it in a secret named elastic-webhook-server-cert in the elastic-system namespace. This certificate is automatically rotated by the operator when it is due to expire.
##### certificate signed by CA
- signed Subject Alternative Name (SAN) of the form 
    <service_name>.<namespace>.svc
    (eg. elastic-webhook-server.elastic-system.svc)

```
openssl req -x509 -sha256 -nodes -newkey rsa:4096 -days 365 -subj "/CN=elastic-webhook-server" -addext "subjectAltName=DNS:elastic-webhook-server.elastic-system.svc" -keyout tls.key -out tls.crt
```
- create secret
```
kubectl create secret -n elastic-system generic elastic-webhook-server-custom-cert --from-file=tls.crt=tls.crt --from-file=tls.key=tls.key
```
- encode CA trust chain as base64 and set it as the value of caBundle fields in the validatingWebhookConfiguration
-install operator with:
    - set manage-webhook-certs false
    - webhook-secret to the name of secret (elastic-webhook-server-custom-cert)

###### use certificate from cert-manager
- new certificate
```
apiVersion: cert-manager.io/v1beta1
kind: Certificate
metadata:
  name: elastic-webhook-server-cert
  namespace: elastic-system
spec:
  dnsNames:
    - elastic-webhook-server.elastic-system.svc
  issuerRef:
    kind: ClusterIssuer
    name: self-signing-issuer
  secretName: elastic-webhook-server-cert
```

- annotate the ValidatingWebhookConfiguration to inject the CA bundle:
```
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  annotations:
    cert-manager.io/inject-ca-from: elastic-system/elastic-webhook-server-cert
  name: elastic-webhook.k8s.elastic.co
webhooks:
[...]
```
- Install the operator with the following options:

Set manage-webhook-certs to false
Set webhook-secret to the name of the certificate secret (elastic-webhook-server-cert)

- when running eks container with elasticsearch disable the ability to use memory-mapping 
  node.store.allow_mmap: false

  https://www.elastic.co/guide/en/elasticsearch/reference/7.3/index-modules-store.html#allow-mmap

  if whithout this startup check with bootstrap failed
  ```
  ERROR: [1] bootstrap checks failed
  [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
  ```

  