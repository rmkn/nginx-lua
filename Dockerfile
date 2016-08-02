FROM centos:6
MAINTAINER rmkn
RUN cp -p /usr/share/zoneinfo/Japan /etc/localtime && echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock
RUN yum -y update
RUN yum -y install gcc pcre-devel zlib-devel

RUN curl -o /usr/local/luajit.tar.gz -SL http://luajit.org/download/LuaJIT-2.0.4.tar.gz \
	&& tar zxf /usr/local/luajit.tar.gz -C /usr/local/src \
	&& cd /usr/local/src/LuaJIT-2.0.4 \
	&& make PREFIX=/usr/local/luajit \
	&& make install PREFIX=/usr/local/luajit

RUN curl -o /usr/local/src/ndk.tar.gz -SL https://github.com/simpl/ngx_devel_kit/archive/v0.3.0.tar.gz \
	&& tar zxf /usr/local/src/ndk.tar.gz -C /usr/local/src

RUN curl -o /usr/local/src/lua-nginx.tar.gz -SL https://github.com/openresty/lua-nginx-module/archive/v0.10.5.tar.gz \
	&& tar zxf /usr/local/src/lua-nginx.tar.gz -C /usr/local/src

RUN curl -o /usr/local/src/nginx.tar.gz -SL https://nginx.org/download/nginx-1.10.1.tar.gz \
	&& export LUAJIT_LIB=/usr/local/luajit/lib \
	&& export LUAJIT_INC=/usr/local/luajit/include/luajit-2.0 \
	&& tar zxf /usr/local/src/nginx.tar.gz -C /usr/local/src \
	&& cd /usr/local/src/nginx-1.10.1 \
	&& ./configure --prefix=/opt/nginx --with-ld-opt="-Wl,-rpath,/usr/local/luajit/lib" --add-module=../ngx_devel_kit-0.3.0 --add-module=../lua-nginx-module-0.10.5 \
	&& make -j2 \
	&& make install

EXPOSE 80

CMD ["/opt/nginx/sbin/nginx", "-g", "daemon off;"]
