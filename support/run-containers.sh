#!/bin/bash

# Load support script
export PWD=$(pwd)

# ES
es(){
    docker run -d \
        --name "$ES" \
        -p 9200:9200 \
        -p 9300:9300 \
        -v "$PWD":/usr/share/elasticsearch/data \
        -v "$PWD"/elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
        -v "$PWD"/elasticsearch/config/jvm.options:/usr/share/elasticsearch/config/jvm.options \
        -e "bootstrap.memory_lock=true" \
        -e ES_JAVA_OPTS="-Xms1g -Xmx1g" \
        --ulimit nofile=65536:65536 \
        --ulimit memlock=-1:-1 \
	    docker.elastic.co/"$ES"/"$ES":6.4.2
    CONTAINER="$ES"
}

# NX
nx(){
    docker run -d \
        --name "$NX" \
        -p 80:80 \
        -v "$PWD"/nginx/kibana.conf:/etc/nginx/conf.d/default.conf \
	    --link "$KB" \
        "$NX":latest
    CONTAINER="$NX"
}

# KB
kb(){
    docker run -d \
        --name "$KB" \
        -p 5601:5601 \
	    -v "$PWD"/kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml \
	    -e SERVER_NAME=localhost \
	    -e ELASTICSEARCH_URL=http://elasticsearch:9200 \
	    --link "$ES" \
	    docker.elastic.co/"$KB"/"$KB":6.4.2
    CONTAINER="$KB"
}

# Run Containers
run-containers(){
    case "$1" in
    "$ES") es && get_running_container "$ES"
            if [ "$?" -eq 0 ]; then
                health_check_http http://localhost:9200
            else
                exit 1
            fi ;;
    "$KB") kb && get_running_container "$KB"
            if [ "$?" -eq 0 ]; then
                health_check_http http://localhost:5601
            else
                exit 1
            fi ;;
    "$NX") nx && get_running_container "$NX"
            if [ "$?" -eq 0 ]; then
                health_check_http http://localhost
            else
                exit 1
            fi ;;
    esac
}
