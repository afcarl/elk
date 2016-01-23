# Dockerfile for ELK stack on Ubuntu base

# Help:
# 80=nginx, 9200=elasticsearch, 5140=logstash udp input
# Default command: docker run -d -v /conf/logstash:/conf -p 80:80 -p 5140:5140/udp -p 9200:9200 northshore/elk /elk_start.sh
# Default command will start ELK within a docker
# To login to bash: docker run -t -v /conf/logstash:/conf -i northshore/elk /bin/bash


FROM ubuntu:15.10
MAINTAINER DIREKTSPEED
## needs upgrading!
ENV KIBANA_VER 3.1.0
ENV ELS_VER 1.3.1
ENV LOGSTASH_VER 1.4.2

# Initial update 
RUN apt-get update \
 && echo "# Install curl utility just for testing \n" \
 && apt-get install -y software-properties-common  curl nginx\
 && echo "# Install Nginx \n # Start or stop with /etc/init.d/nginx start/stop. Runs on port 80. \n # Sed command is to make the worker threads of nginx run as user root" \
 && sed -i -e 's/www-data/root/g' /etc/nginx/nginx.conf \
 && echo "# This is to install add-apt-repository utility. All commands have to be non interactive with -y option \n" \
 && echo "# Install Oracle Java 8, accept license command is required for non interactive mode \n"
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 \
 && add-apt-repository -y ppa:webupd8team/java \
 && apt-get update \
 && echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections \
 && apt-get install -y oracle-java8-installer \
 && wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${ELS_VER}.tar.gz \
 && echo "# Elasticsearch installation \n Start Elasticsearch by /elasticsearch/bin/elasticsearch. This will run on port 9200."
 && tar xf elasticsearch-${ELS_VER}.tar.gz \
 && rm elasticsearch-${ELS_VER}.tar.gz && \
 && mv elasticsearch-${ELS_VER} elasticsearch \
 && echo "# Logstash installation \n # Create a logstash.conf and start logstash by /logstash/bin/logstash agent -f logstash.conf" \
 && wget https://download.elasticsearch.org/logstash/logstash/logstash-${LOGSTASH_VER}.tar.gz \
 && tar xf logstash-${LOGSTASH_VER}.tar.gz \
 && rm logstash-${LOGSTASH_VER}.tar.gz \
 && mv logstash-${LOGSTASH_VER} logstash \
 && echo "# Kibana installation \n" \
 && wget https://download.elasticsearch.org/kibana/kibana/kibana-${KIBANA_VER}.tar.gz \
 && tar xf kibana-${KIBANA_VER}.tar.gz \
 && rm kibana-${KIBANA_VER}.tar.gz \
 && mv kibana-${KIBANA_VER}  kibana \
 && echo "# Deploy kibana ${KIBANA_VER} to Nginx \n" \
 && mv /usr/share/nginx/html /usr/share/nginx/html_orig \
 && mkdir /usr/share/nginx/html \
 && cp -r /kibana/* /usr/share/nginx/html

# Create a start bash script
RUN touch elk_start.sh && \
   echo '#!/bin/bash' >> elk_start.sh && \
   echo '/elasticsearch/bin/elasticsearch &' >> elk_start.sh && \
   echo 'cp -r /conf/dashboards/* /usr/share/nginx/html/app/dashboards/ ' >> elk_start.sh && \
   echo '/etc/init.d/nginx start &' >> elk_start.sh && \
   echo 'exec /logstash/bin/logstash agent -f /conf/logstash.conf' >> elk_start.sh && \
   chmod 777 elk_start.sh

## TODO
# expose ports write documentation
# 80=nginx, 9200=elasticsearch, 5140=logstash 443=ssl support if no external offloading. udp input
EXPOSE 80 4439200 5140
CMD /elk_start.sh
