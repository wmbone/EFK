Ingest data from other sources by installing and configuring other Elastic Beats:

Elastic Beats	To capture
Filebeat        Logs

Winlogbeat      Windows event logs

Heartbeat       Uptime information

APM             Application performance metrics

Auditbeat       Audit events

https://www.elastic.co/guide/en/beats/metricbeat/7.10/metricbeat-installation-configuration.html

Use the Observability apps in Kibana to search across all your data:

Elastic apps	Use to
Metrics app     Explore metrics about systems and services across your ecosystem

Logs app        Tail related log data in real time

Uptime app      Monitor availability issues across your apps and services

APM app         Monitor application performance

SIEM app        Analyze security events

## TLS SSL certificate
https://www.elastic.co/guide/en/beats/metricbeat/current/configuration-ssl.html

- example metricbeat-reference.yaml
https://www.elastic.co/guide/en/beats/metricbeat/current/metricbeat-reference-yml.html
on my lab with xpack.enabled, but ssl verification_mode "none" and still see this message on metricbeat logs. Data do sucessful send to elasticsearch and Kibana right now.

```
2020-12-13T10:55:11.402Z	WARN	[tls]	tlscommon/tls_config.go:93	SSL/TLS verifications disabled.
```
```
    output.elasticsearch:
    # hosts: ['${ELASTICSEARCH_HOST:elasticsearch}:${ELASTICSEARCH_PORT:9200}']
      hosts: ['https://10.111.179.147:9200']
      username: elastic
      password: #{ ENV['ELASTICSEARCH_PASSWORD'] }
      xpack.enabled: true
      ssl.verification_mode: "none"
      ssl.certificate_autorities:
        - |
          -----BEGIN CERTIFICATE-----
          MIID0TCCArmgAwIBAgIRAOPlgwNlkma+qfpQuhEox/swDQYJKoZIhvcNAQELBQAw
          LzETMBEGA1UECxMKcXVpY2tzdGFydDEYMBYGA1UEAxMPcXVpY2tzdGFydC1odHRw
```

## configure metricbeat
https://www.elastic.co/guide/en/beats/metricbeat/7.10/configuring-howto-metricbeat.html

- kibana and load dashboard
```
    setup.kibana:
      host: "10.102.229.230:5601"
      protocol: "https"
      username: "elastic"
      password: "#{ ENV['ELASTICSEARCH_PASSWORD'] }"
      ssl.verification_mode: "none"
    setup.dashboards.enabled: true
```