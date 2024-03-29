FROM alpine:3.12

RUN		sed -i "s/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g" /etc/apk/repositories

RUN		apk update && apk upgrade
RUN		apk add --no-cache \
		nginx \
		openssl \
		openssh

# ssl
RUN		openssl req -newkey rsa:4096 -nodes -x509 -keyout /etc/ssl/private/nginx.key -out /etc/ssl/certs/nginx.crt -days 365 -subj "/C=KR/L=GUN/O=42Seoul/OU=junmkang/CN=nginx" \
&&		chmod 600 /etc/ssl/private/nginx.key /etc/ssl/certs/nginx.crt

# ssh
RUN		adduser -D -g 'www' www \
&&		mkdir /www \
&&		chown -R www:www /var/lib/nginx \
&&		chown -R www:www /www \
&&		mkdir -p /run/nginx

COPY	./srcs/index.html /www/index.html
COPY	./srcs/nginx.conf /etc/nginx/nginx.conf
COPY	./srcs/default.conf /etc/nginx/conf.d/default.conf
# COPY	./srcs/nginx_service.conf /etc/nginx/conf.d/nginx_service.conf
COPY	./srcs/nginx_setup.sh .

RUN	chmod +x nginx_setup.sh

EXPOSE 80 443

CMD ["./nginx_setup.sh"]
