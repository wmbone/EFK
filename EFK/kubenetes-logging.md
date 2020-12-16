# kubernetes logging
https://medium.com/kubernetes-tutorials/cluster-level-logging-in-kubernetes-with-fluentd-e59aa2b6093a

- container write logs to stdout and stderr and kubernetes refirect to a logging driver to wirte file in JSON format, then exposes log file to user via kubectl logs
- "--previous" to true can get container logs if the container crashed and was restarted.

