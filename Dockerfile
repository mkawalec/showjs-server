FROM base/devel
MAINTAINER Michal Kawalec <michal@bazzle.me>

ENV NODE_ENV development

RUN pacman -Sy --noconfirm --needed python2 nodejs hiredis 
RUN npm install -g LiveScript gulp knex

RUN mkdir -p /code
VOLUME /code
ADD . /code
WORKDIR /code
