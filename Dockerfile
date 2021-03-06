FROM python:2.7-alpine
MAINTAINER Rafael Dreher <dreher@me.com>

# get latest source code
ENV REQUESTBIN_VERSION master

ADD https://github.com/Runscope/requestbin/archive/${REQUESTBIN_VERSION}.zip /

RUN unzip ${REQUESTBIN_VERSION}.zip && \
      rm ${REQUESTBIN_VERSION}.zip && \
      mv requestbin-${REQUESTBIN_VERSION} /app

RUN apk update && apk upgrade && \
    apk add \
        gcc python python-dev py-pip \
        # greenlet
        musl-dev \
        # sys/queue.h
        bsd-compat-headers \
        # event.h
        libevent-dev \
    && rm -rf /var/cache/apk/*

WORKDIR /app

RUN pip install --quiet --disable-pip-version-check -r requirements.txt

ENV PORT 80
EXPOSE 80

CMD gunicorn --bind=0.0.0.0:$PORT --worker-class=gevent --workers=2 --max-requests=1000 requestbin:app 
