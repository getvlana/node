#!/bin/sh
# First start: make REALITY keys and register with the enroll token. Later starts: reuse /etc/vlana.
set -eu
SERVER="${VLANA_SERVER:-https://go.vlana.app}"
PORT="${PORT:-443}"
SNI="${SNI:-dl.google.com}"
mkdir -p /etc/vlana /usr/local/etc/xray
chmod 700 /etc/vlana

if [ ! -f /etc/vlana/node.json ]; then
  [ -n "${TOKEN:-}" ] || { echo "set TOKEN to the enroll token from go.vlana.app → Nodes → Add a node"; exit 1; }
  KEYS="$(xray x25519)"
  PRIV="$(echo "$KEYS" | awk -F': ' '/^Private/{print $2}')"
  PUB="$(echo "$KEYS" | awk -F': ' '/Public|Password/{print $2; exit}')"
  SID="$(openssl rand -hex 8)"
  python3 - "$SERVER" "$TOKEN" "$PRIV" "$PUB" "$SID" "$PORT" "$SNI" <<'PY'
import json, sys
s, t, priv, pub, sid, port, sni = sys.argv[1:]
json.dump({"server": s, "enroll": t, "private_key": priv, "public_key": pub,
           "short_id": sid, "port": int(port), "sni": sni}, open('/etc/vlana/node.json', 'w'), indent=1)
PY
  chmod 600 /etc/vlana/node.json
  echo "→ keys created, registering with $SERVER"
fi

SERVER="$(python3 -c "import json;print(json.load(open('/etc/vlana/node.json'))['server'])")"
curl -fsSL "$SERVER/agent.py" -o /usr/local/bin/agent.py

# keep xray up between config changes; the agent restarts it itself when the config changes
( while sleep 15; do [ -f /usr/local/etc/xray/config.json ] && ! pgrep -x xray >/dev/null && restart-xray.sh; done ) &

export XRAY_RESTART=/usr/local/bin/restart-xray.sh
exec python3 /usr/local/bin/agent.py
