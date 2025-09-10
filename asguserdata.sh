#!/bin/bash
hostnamectl set-hostname ussd-api-asg
DD_API_KEY=your_script \
DD_SITE="datadoghq.com" \
bash -c "$(curl -L https://install.datadoghq.com/scripts/install_script_agent7.sh)"

cat >> /etc/datadog-agent/datadog.yaml << EOF
process_config:
  process_collection:
    enabled: true
EOF

systemctl restart datadog-agent
docker ps > /home/docker.text