FROM debian:bookworm-slim

ARG VERSION
ARG SEMVER_CORE
ARG COMMIT_SHA
ARG GITHUB_REPO
ARG BUILD_DATE

ENV VERSION=${VERSION}
ENV SEMVER_CORE=${SEMVER_CORE}
ENV COMMIT_SHA=${COMMIT_SHA}
ENV BUILD_DATE=${BUILD_DATE}
ENV GITHUB_REPO=${GITHUB_REPO}

LABEL org.opencontainers.image.source=${GITHUB_REPO}
LABEL org.opencontainers.image.created=${BUILD_DATE}
LABEL org.opencontainers.image.version=${VERSION}
LABEL org.opencontainers.image.revision=${COMMIT_SHA}

RUN set -xe \
    && apt-get update \
    && apt-get install -y --no-install-recommends nginx-light libnginx-mod-http-lua iproute2 traceroute iputils-ping curl less ca-certificates bind9-dnsutils nmap telnet netcat-openbsd tcptraceroute ngrep \
    && rm /etc/nginx/sites-enabled/* \
    && ln -s /etc/nginx/sites-available/debdiag /etc/nginx/sites-enabled/ \
    && sed -i /^user/d /etc/nginx/nginx.conf \
    && chown  --recursive  www-data  /var/lib/nginx /run \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

ADD debdiag /etc/nginx/sites-available/

STOPSIGNAL SIGTERM

# USER www-data

CMD ["nginx", "-g", "daemon off;"]
