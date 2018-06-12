FROM centos:6
MAINTAINER rmkn
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8 && sed -i -e "s/en_US.UTF-8/ja_JP.UTF-8/" /etc/sysconfig/i18n
RUN cp -p /usr/share/zoneinfo/Japan /etc/localtime && echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock
RUN yum -y update
RUN yum -y install gcc pcre-devel zlib-devel

ENV NGINX_VERSION 1.14.0
ENV LUAJIT_VERSION 2.0.5
ENV NDK_VERSION 0.3.0
ENV LUAMOD_VERSION 0.10.13

RUN curl -o /usr/local/src/luajit.tar.gz -SL http://luajit.org/download/LuaJIT-${LUAJIT_VERSION}.tar.gz \
	&& tar zxf /usr/local/src/luajit.tar.gz -C /usr/local/src \
	&& cd /usr/local/src/LuaJIT-${LUAJIT_VERSION} \
	&& make PREFIX=/usr/local/luajit \
	&& make install PREFIX=/usr/local/luajit

RUN curl -o /usr/local/src/ndk.tar.gz -SL https://github.com/simpl/ngx_devel_kit/archive/v${NDK_VERSION}.tar.gz \
	&& tar zxf /usr/local/src/ndk.tar.gz -C /usr/local/src

RUN curl -o /usr/local/src/lua-nginx.tar.gz -SL https://github.com/openresty/lua-nginx-module/archive/v${LUAMOD_VERSION}.tar.gz \
	&& tar zxf /usr/local/src/lua-nginx.tar.gz -C /usr/local/src

ENV LUAJIT_LIB /usr/local/luajit/lib
ENV LUAJIT_INC /usr/local/luajit/include/luajit-2.0

RUN curl -o /usr/local/src/nginx.tar.gz -SL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
	&& tar zxf /usr/local/src/nginx.tar.gz -C /usr/local/src \
	&& cd /usr/local/src/nginx-${NGINX_VERSION} \
	&& ./configure --prefix=/usr/local/nginx --with-ld-opt="-Wl,-rpath,/usr/local/luajit/lib" --add-module=../ngx_devel_kit-${NDK_VERSION} --add-module=../lua-nginx-module-${LUAMOD_VERSION} \
	&& make \
	&& make install

COPY nginx.conf /usr/local/nginx/conf/
COPY virtual.conf /usr/local/nginx/conf/conf.d/

EXPOSE 80

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
