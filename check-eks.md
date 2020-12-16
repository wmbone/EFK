# check EKS and collected stream
Elasticsearch
- Cluster settings

https://localhost:9200/_cluster/settings
{"persistent":{},"transient":{"cluster":{"routing":{"allocation":{"exclude":{"_name":"none_excluded"}}}}}}

https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-metricbeat.html

- enable collection of mpnitoring data

```
curl -X GET "localhost:9200/_cluster/settings?pretty"
curl -X PUT "localhost:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "xpack.monitoring.collection.enabled": true
  }
}
'
```
or on postman put request with body json
```
{
      "persistent": {
    "xpack.monitoring.collection.enabled": true
    }
  }
```

result:

{"persistent":{"xpack":{"monitoring":{"collection":{"enabled":"true"}}}},"transient":{"cluster":{"routing":{"allocation":{"exclude":{"_name":"none_excluded"}}}}}}


## Elasticserch api
- stats can show index stream as well
https://localhost:9200/_nodes/stats
example:
https://localhost:9200/logstash-2020.12.14/


https://localhost:9200/_nodes/stats/http


