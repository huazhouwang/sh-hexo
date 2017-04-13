FROM node
MAINTAINER wang huazhou "huazhou19@gmail.com"

# install hexo

RUN npm install -g hexo-cli

ENV root=/hexo 
WORKDIR ${root}

CMD npm install && \
    hexo server -p 4000
