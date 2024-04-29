#!/bin/bash
# ВЕРСИЯ 2.51.2

PROMETHEUS_VERSION="2.51.2"
PROMETHEUS_FOLDER_CONFIG="/etc/prometheus"
PROMETHEUS_FOLDER_TSDATA="/etc/prometheus/data"

cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.51.2/prometheus-2.51.2.linux-amd64.tar.gz
tar xf prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
cd prometheus

mv prometheus /usr/bin/
rm -rf /tmp/prometheus*

mkdir -p $PROMETHEUS_FOLDER_CONFIG
mkdir -p $PROMETHEUS_FOLDER_TSDATA


cat <<EOF> $PROMETHEUS_FOLDER_CONFIG/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name      : "prometheus"
    static_configs:
      - targets: ["localhost:9090"]
EOF

useradd -rs /bin/false prometheus
chown prometheus:prometheus /usr/bin/prometheus
chown prometheus:prometheus $PROMETHEUS_FOLDER_CONFIG
chown prometheus:prometheus $PROMETHEUS_FOLDER_CONFIG/prometheus.yml
chown prometheus:prometheus $PROMETHEUS_FOLDER_TSDATA



cat <<EOF> /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Server
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
ExecStart=/usr/bin/prometheus \
  --config.file       ${PROMETHEUS_FOLDER_CONFIG}/prometheus.yml \
  --storage.tsdb.path ${PROMETHEUS_FOLDER_TSDATA}

[Install]
WantedBy=multi-user.target
EOF


systemctl start prometheus
systemctl enable --now prometheus
systemctl status prometheus