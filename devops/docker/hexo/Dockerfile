FROM node:7.9.0-alpine
MAINTAINER wang huazhou "huazhou19@gmail.com"

# install hexo

RUN npm update && \
    npm install -g hexo-cli

ENV root=/hexo 
WORKDIR ${root}

CMD npm install && \
    hexo server -p 4000
