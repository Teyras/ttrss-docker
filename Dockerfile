FROM docker.io/ubuntu:groovy AS builder

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt -y install git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://git.tt-rss.org/fox/tt-rss.git /tt-rss

WORKDIR /tt-rss
ARG revision=8ed927dbd2
RUN git pull origin master && git checkout $revision && rm -rf .git

FROM docker.io/ubuntu:groovy

EXPOSE 9000/tcp
ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /tt-rss

ENV TTRSS_DB_HOST=""
ENV TTRSS_DB_NAME=""
ENV TTRSS_DB_USER=""
ENV TTRSS_DB_PASS=""
ENV TTRSS_SELF_URL_PATH=""

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt -y install uwsgi-core uwsgi-plugin-php \
    php7.4 php7.4-gd php7.4-pgsql php7.4-mbstring php7.4-intl \
    php7.4-xml php7.4-curl php7.4-json php7.4-zip postgresql-client \
    && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
COPY --from=builder /tt-rss /tt-rss

RUN chmod -R 777 /tt-rss/cache /tt-rss/feed-icons /tt-rss/lock \
    && useradd -r ttrss \
    && chown -R ttrss /tt-rss

USER ttrss
