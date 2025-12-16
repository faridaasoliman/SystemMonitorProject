FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       bash \
       cron \
       procps \
       lm-sensors \
       smartmontools \
       iproute2 \
       iputils-ping \
       net-tools \
       gettext-base \
       libnotify-bin \
       dos2unix \
             zenity \
             python3-tk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/system-monitor

# Copy project files
COPY . /opt/system-monitor

# Ensure scripts are executable, normalize line endings, and ensure logs dir exists
RUN chmod -R +x /opt/system-monitor/scripts /opt/system-monitor/dashboard || true \
    && find /opt/system-monitor -type f -name "*.sh" -exec dos2unix {} \; || true \
    && mkdir -p /opt/system-monitor/logs

# Add entrypoint
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN dos2unix /usr/local/bin/entrypoint.sh || true \
    && chmod +x /usr/local/bin/entrypoint.sh

VOLUME ["/opt/system-monitor/logs"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["cron", "-f"]
