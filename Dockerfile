
FROM phusion/passenger-full:0.9.18

ENV HOME /root

RUN mkdir -p /home/app/webapp
WORKDIR /home/app/webapp

ADD docker/secret_key.conf /etc/nginx/main.d/secret_key.conf
ADD docker/gzip_max.conf /etc/nginx/conf.d/gzip_max.conf
ADD docker/.irbrc /home/app/.irbrc

RUN rm /etc/nginx/sites-enabled/default
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/service/redis/down

RUN apt-get update
RUN apt-get install -y wget git nano curl
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update
RUN apt-get install -y postgresql

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gem install rails
RUN gem install pg && \
    gem install hirb-unicode && \
    gem install better_errors && \
    gem install web-console && \
    gem install dotenv-rails && \
    gem install redis && \
    gem install minitest-reporters

ARG uid=9999
ARG gid=9999
RUN usermod -u $uid app && groupmod -g $gid app

RUN chown -R app:app /home/app

RUN echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ADD . /home/app/webapp/
RUN su - app -c "cd /home/app/webapp && sudo bundle install"

CMD ["/sbin/my_init"]
