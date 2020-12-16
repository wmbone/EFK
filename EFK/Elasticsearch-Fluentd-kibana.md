# elasticsearch fluentd and kibana stack
https://www.digitalocean.com/community/tutorials/how-to-set-up-an-elasticsearch-fluentd-and-kibana-efk-logging-stack-on-kubernetes
https://opendevops.in/2019/12/27/setup-elastic-search-cluster-kibana-fluentd-on-kubernetes-with-x-pack-security-part-3/
https://github.com/fluent/fluentd-kubernetes-daemonset
https://github.com/uken/fluent-plugin-elasticsearch

- elasticsearch_svc.yaml headless DNS for elasticsearch service 

## output elasticsearch for fluentd
https://docs.fluentd.org/output/elasticsearch

- The out_elasticsearch Output plugin writes records into Elasticsearch. By default, it creates records using bulk api which performs multiple indexing operations in a single API call.

Installation
Since out_elasticsearch has been included in the standard distribution of td-agent since v3.0.1, td-agent users do not need to install it manually.

- on container image /fluentd/etc/fluent.conf define route
on multiple host and with authentication can use this
```
hosts host1:port1,host2:port2,host3:port3
# or
hosts https://customhost.com:443/path,https://username:password@host-failover.com:443
```
I don't found the option user, password on the fluentd.conf on the container image I used.

```
<match **>
   @type elasticsearch
   @id out_es
   @log_level info
   include_tag_key true
   host "#{ENV['FLUENT_ELASTICSEARCH_HOST']}"
   port "#{ENV['FLUENT_ELASTICSEARCH_PORT']}"
   path "#{ENV['FLUENT_ELASTICSEARCH_PATH']}"
   scheme "#{ENV['FLUENT_ELASTICSEARCH_SCHEME'] || 'http'}"
   ssl_verify "#{ENV['FLUENT_ELASTICSEARCH_SSL_VERIFY'] || 'true'}"
   ssl_version "#{ENV['FLUENT_ELASTICSEARCH_SSL_VERSION'] || 'TLSv1'}"
   reload_connections "#{ENV['FLUENT_ELASTICSEARCH_RELOAD_CONNECTIONS'] || 'false'}"
   reconnect_on_error "#{ENV['FLUENT_ELASTICSEARCH_RECONNECT_ON_ERROR'] || 'true'}"
   reload_on_failure "#{ENV['FLUENT_ELASTICSEARCH_RELOAD_ON_FAILURE'] || 'true'}"
   log_es_400_reason "#{ENV['FLUENT_ELASTICSEARCH_LOG_ES_400_REASON'] || 'false'}"
   logstash_prefix "#{ENV['FLUENT_ELASTICSEARCH_LOGSTASH_PREFIX'] || 'logstash'}"
   logstash_format "#{ENV['FLUENT_ELASTICSEARCH_LOGSTASH_FORMAT'] || 'true'}"
   index_name "#{ENV['FLUENT_ELASTICSEARCH_LOGSTASH_INDEX_NAME'] || 'logstash'}"
   type_name "#{ENV['FLUENT_ELASTICSEARCH_LOGSTASH_TYPE_NAME'] || 'fluentd'}"
   <buffer>
     flush_thread_count "#{ENV['FLUENT_ELASTICSEARCH_BUFFER_FLUSH_THREAD_COUNT'] || '8'}"
     flush_interval "#{ENV['FLUENT_ELASTICSEARCH_BUFFER_FLUSH_INTERVAL'] || '5s'}"
     chunk_limit_size "#{ENV['FLUENT_ELASTICSEARCH_BUFFER_CHUNK_LIMIT_SIZE'] || '2M'}"
     queue_limit_length "#{ENV['FLUENT_ELASTICSEARCH_BUFFER_QUEUE_LIMIT_LENGTH'] || '32'}"
     retry_max_interval "#{ENV['FLUENT_ELASTICSEARCH_BUFFER_RETRY_MAX_INTERVAL'] || '30'}"
     retry_forever true
   </buffer>
</match>
```
1. “match” tag indicates a destination. It is followed by a regular expression for matching the source. In this case, we want to capture all logs and send them to Elasticsearch, so simply use **
2. id: Unique identifier of the destination
3. type: Supported output plugin identifier. In this case, we are using ElasticSearch which is a built-in plugin of fluentd.
4. log_level: Indicates which logs to capture. In this case, any log with level “info” and above – INFO, WARNING, ERROR – will be routed to Elasticsearch.
5. host/port: ElasticSearch host/port. Credentials can be configured as well, but not shown here.
6. logstash_format: The Elasticsearch service builds reverse indices on log data forward by fluentd for searching. Hence, it needs to interpret the data. By setting logstash_format to “true”, fluentd forwards the structured log data in logstash format, which Elasticsearch understands.
7. Buffer: fluentd allows a buffer configuration in the event the destination becomes unavailable. e.g. If the network goes down or ElasticSearch is unavailable. Buffer configuration also helps reduce disk activity by batching writes.

and deployment fluentd.yaml
```
    spec:
      serviceAccount: fluentd
      serviceAccountName: fluentd
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      containers:
      - name: fluentd
        image: fluent/fluentd-kubernetes-daemonset:v1.4.2-debian-elasticsearch-1.1
        env:
          - name:  FLUENT_ELASTICSEARCH_HOST
            value: "10.111.179.147"
          - name:  FLUENT_ELASTICSEARCH_PORT
            value: "9200"
          - name: FLUENT_ELASTICSEARCH_SCHEME
            value: "http"
          - name: FLUENTD_SYSTEMD_CONF
            value: disable
```

### Kubernetes logging
- /fluentd/etc/kubernetes.conf

- define source
```
<source>
  @type tail
  @id in_tail_container_logs
  path /var/log/containers/*.log
  pos_file /var/log/fluentd-containers.log.pos
  tag kubernetes.*
  read_from_head true
  <parse>
    @type "#{ENV['FLUENT_CONTAINER_TAIL_PARSER_TYPE'] || 'json'}"
    time_format %Y-%m-%dT%H:%M:%S.%NZ
  </parse>
</source>
```
1. id: A unique identifier to reference this source. This can be used for further filtering and routing of structured log data
2. type: Inbuilt directive understood by fluentd. In this case, “tail” instructs fluentd to gather data by tailing logs from a given location. Another example is “http” which instructs fluentd to collect data by using GET on http endpoint.
3. path: Specific to type “tail”. Instructs fluentd to collect all logs under /var/log/containers directory. This is the location used by docker daemon on a Kubernetes node to store stdout from running containers.
4. pos_file: Used as a checkpoint. In case the fluentd process restarts, it uses the position from this file to resume log data collection
5. tag: A custom string for matching source to destination/filters. fluentd matches source/destination tags to route log data


#### Fluentd Elasticsearch communication error
- http -> https
- added username:password
```
curl -k https://10.111.179.147:9200
{"error":{"root_cause":[{"type":"security_exception","reason":"missing authentication credentials for REST request [/]","header":{"WWW-Authenticate":["Basic realm=\"security\" charset=\"UTF-8\"","Bearer realm=\"security\"","ApiKey"]}}],"type":"security_exception","reason":"missing authentication credentials for REST request [/]","header":{"WWW-Authenticate":["Basic realm=\"security\" charset=\"UTF-8\"","Bearer re/ # curl -k https://elastic:#{ ENV['ELASTICSEARCH_PASSWORD'] }@10.111.179.147:9200
{
  "name" : "quickstart-es-default-0",
  "cluster_name" : "quickstart",
  "cluster_uuid" : "NYnvvZLNR5e43Md-9CfcBw",
  "version" : {
    "number" : "7.10.0",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "51e9d6f22758d0374a0f3f5c6e8f3a7997850f96",
    "build_date" : "2020-11-09T21:30:33.964949Z",
    "build_snapshot" : false,
    "lucene_version" : "8.7.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```
##### Kubernetes.conf
https://github.com/fluent/fluentd-kubernetes-daemonset/blob/master/templates/conf/kubernetes.conf.erb