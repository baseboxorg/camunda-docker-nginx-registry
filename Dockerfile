FROM nginx:latest

RUN apt-get update -qq && \
    apt-get install -qqy --no-install-recommends apache2-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /etc/nginx/conf.d/*

ADD ssl/ /etc/nginx/ssl

ADD conf.d/* /etc/nginx/conf.d/

ADD bin/* /usr/local/bin/

CMD ["/usr/local/bin/start-nginx.sh"]
