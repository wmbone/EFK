# Setup EFK Elasticsearch Fluentd Kibana with operator on Kubernetes

![EFK stack](/image/Elasticsearch-Fluentd-logstack.png)

This setup based on Elastic Cloud on K8 stack 
https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html

using operator and install all-in-one Elasticsearch with Kibana on a 4 node kubernetes cluster.

Elastic cloud deploy on the master node and
metricbeat and fluentd deploy on each node to collect metric and logging.

![logstash](/image/kibana-logstash.PNG)
![metricbeat](/image/kibana-metricbeat.PNG)
![Kubernetes Dashboard](/image/kubernetes-dashboard.PNG)
