#!/bin/sh
# Removes a node installed with install.sh. Remove it in the app too (Nodes → remove) so it leaves the list.
set -e
[ "$(id -u)" = 0 ] || { echo "run as root"; exit 1; }
systemctl disable --now vlana-agent 2>/dev/null || true
rm -f /etc/systemd/system/vlana-agent.service
systemctl daemon-reload
rm -rf /opt/vlana /etc/vlana
if [ "${1:-}" = "--xray" ]; then
  bash -c "$(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
else
  systemctl disable --now xray 2>/dev/null || true
  echo "xray stopped but left installed. run with --xray to remove it too"
fi
echo "done"
