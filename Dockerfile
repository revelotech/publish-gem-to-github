FROM ruby:3.3-alpine

RUN apk add --no-cache git

RUN set -x \
  && gem install bundler keycutter

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
