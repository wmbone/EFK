# issue note on ssl and tls
https://github.com/fluent/fluentd-kubernetes-daemonset/blob/master/fluentd-daemonset-elasticsearch.yaml

- elasticsearch all in one with tls enabled, try enables tls and ssl on fluentd

172.18.0.4,5,8
Elastic search endpoint 10.244.185.53:9200

{"type": "server", "timestamp": "2020-12-10T07:00:17,500Z", "level": "WARN", "component": "o.e.x.s.t.n.SecurityNetty4HttpServerTransport", "cluster.name": "quickstart", "node.name": "quickstart-es-default-0", "message": "received plaintext http traffic on an https channel, closing connection Netty4HttpChannel{localAddress=/10.244.185.53:9200, remoteAddress=/172.18.0.5:31370}", "cluster.uuid": "NYnvvZLNR5e43Md-9CfcBw", "node.id": "m2Y_eR1cTI6gRMcPnyLDpg"  }

## TLS 
https://github.com/elastic/cloud-on-k8s/blob/master/docs/orchestrating-elastic-stack-applications/accessing-elastic-services.asciidoc

Access the Elasticsearch endpoint
You can access the Elasticsearch endpoint within or outside the Kubernetes cluster.

Within the Kubernetes cluster

Retrieve the CA certificate.

Retrieve the password of the elastic user.
```
NAME=hulk

kubectl get secret "$NAME-es-http-certs-public" -o go-template='{{index .data "tls.crt" | base64decode }}' > tls.crt
PW=$(kubectl get secret "$NAME-es-elastic-user" -o go-template='{{.data.elastic | base64decode }}')

curl --cacert tls.crt -u elastic:$PW https://$NAME-es-http:9200/
```
Outside the Kubernetes cluster

Retrieve the CA certificate.

Retrieve the password of the elastic user.

Retrieve the IP of the LoadBalancer Service.
```
NAME=hulk

kubectl get secret "$NAME-es-http-certs-public" -o go-template='{{index .data "tls.crt" | base64decode }}' > tls.crt
IP=$(kubectl get svc "$NAME-es-http" -o jsonpath='{.status.loadBalancer.ingress[].ip}')
PW=$(kubectl get secret "$NAME-es-elastic-user" -o go-template='{{.data.elastic | base64decode }}')

curl --cacert tls.crt -u elastic:$PW https://$IP:9200/
```

### 
- Fluentd deploy as daemon set
- note FLUENT_ELASTICSEARCH_SSL_VERIFY is misspelled and correct it
- change IP back to svc quickstart-es-http clusterIP 10.111.179.147
```
kubectl get svc
NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
kubernetes                ClusterIP   10.96.0.1        <none>        443/TCP    58d
quickstart-es-default     ClusterIP   None             <none>        9200/TCP   8d
quickstart-es-http        ClusterIP   10.111.179.147   <none>        9200/TCP   8d
quickstart-es-transport   ClusterIP   None             <none>        9300/TCP   8d
quickstart-kb-http        ClusterIP   10.102.229.230   <none>        5601/TCP   7d18h
```
- added xpack username and password
          - name: FLUENT_ELASTICSEARCH_USER
            value: "elastic"
          - name: FLUENT_ELASTICSEARCH_PASSWORD
            value: "Wquwzb053km4q71LtSC67W7

#### now got pattern not match error with a lot of "\"

https://github.com/fluent/fluentd/issues/2545

https://github.com/fluent/fluentd-kubernetes-daemonset#use-fluent_container_tail_exclude_path-to-exclude-specific-container-logs

          - name: FLUENT_CONTAINER_TAIL_EXCLUDE_PATH to prevent tail own logs
            value: "/var/log/containers/fluentd*" 

- added user and password on kubernetes.conf
https://github.com/uken/fluent-plugin-elasticsearch/blob/master/README.ElasticsearchInput.md#user-password-path-scheme-ssl_verify
- added following to prevent read fluent* log and create "//" error
exclude_path "#{ENV['FLUENT_CONTAINER_TAIL_EXCLUDE_PATH'] || use_default}"

https://github.com/fluent/fluentd-kubernetes-daemonset/issues/412