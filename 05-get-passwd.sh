# default user named elastic and source this script to get PASSWORD to current shell
# curl -u "elastic:$PASSWORD" -k "https://localhost:9200
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')