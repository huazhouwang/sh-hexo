FROM node:latest
MAINTAINER wang huazhou "huazhou19@gmail.com"

# install hexo
RUN npm install hexo-cli -g \
	&& npm install hexo-server --save

ENV root=/hexo 
WORKDIR ${root}

CMD ["hexo", "server","-i","0.0.0.0"]
