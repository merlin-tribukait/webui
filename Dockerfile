FROM python:3-alpine

RUN apk add --update --no-cache \
	bash \
	curl \
	supervisor \
	openssl \
	nginx \
	&& rm -rf /var/cache/apk/*

ENV CADVISOR_VERSION 0.24.1

RUN chown -R nginx:nginx /var/lib/nginx

# Add cAdvisor
RUN curl -sSL https://github.com/google/cadvisor/releases/download/v$CADVISOR_VERSION/cadvisor -o /usr/local/bin/cadvisor && \
  chmod +x /usr/local/bin/*

# Add webui
RUN /usr/local/bin/pip install Flask docker-py && \
 	rm -rf /var/cache/apk/*

COPY webui /var/www/webui

# Generate SSL certificate and key
RUN set -xe; \
	apk add --update --no-cache \
		openssl \
	; \
	# Create a folder for custom vhost certs (mount custom certs here)
	mkdir -p /etc/certs/custom; \
	# Generate a self-signed fallback cert
	openssl req \
		-batch \
		-newkey rsa:4086 \
		-x509 \
		-nodes \
		-sha256 \
		-subj "/CN=*.dev.b-connect.eu" \
		-days 3650 \
		-out /etc/certs/server.crt \
		-keyout /etc/certs/server.key;

COPY conf/nginx.conf /etc/nginx/nginx.conf
RUN echo "bconnect:$(openssl passwd -apr1 kiekma)" >> /etc/nginx/.htpasswd

COPY conf/supervisord.conf /etc/supervisor.d/webui.ini

EXPOSE 80
EXPOSE 443

CMD ["supervisord", "-n"]
