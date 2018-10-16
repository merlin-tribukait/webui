FROM docksal/webui

RM /var/www/webui
COPY webui /var/www

COPY conf/nginx.conf /etc/nginx/nginx.conf
RUN echo "bconnect:$(openssl passwd -apr1 kiekma)" >> /etc/nginx/.htpasswd

COPY conf/supervisord.conf /etc/supervisor.d/webui.ini

EXPOSE 80
EXPOSE 443

CMD ["supervisord", "-n"]
