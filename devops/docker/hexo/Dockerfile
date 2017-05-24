FROM node:7.9.0-alpine
MAINTAINER wang huazhou "huazhou19@gmail.com"

# install hexo
RUN npm update && \
    npm config set unsafe-perm true && \
    npm install -g hexo-cli && \
    apk update && \
    apk add curl

ENV root=/hexo 
WORKDIR ${root}

CMD npm install && \
    hexo generate && \
    hexo server -p 4000 -s
