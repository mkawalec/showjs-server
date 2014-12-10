FROM base/devel
MAINTAINER Michal Kawalec <michal@bazzle.me>

ENV NODE_ENV development

RUN pacman -Sy --noconfirm --needed python2 nodejs hiredis 
RUN npm install -g LiveScript gulp knex

RUN mkdir /service
WORKDIR /service
ADD package.json /service/package.json
RUN npm install --python=python2

VOLUME /service/code
WORKDIR /service/code
