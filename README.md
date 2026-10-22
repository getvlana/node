# Run a Vlana node

[![image](../../actions/workflows/image.yml/badge.svg)](../../actions/workflows/image.yml)

Get paid in SOL every hour your node stays up. You need a server with a public IPv4, an open TCP port (443 is best) and an **enroll token** from [go.vlana.app](https://go.vlana.app) → **Nodes** → **Add a node**.

Pick one of three ways. All of them run the same thing: real [Xray](https://github.com/XTLS/Xray-core) with VLESS + REALITY, and the [node agent](https://github.com/getvlana/vlana/blob/main/app/node/agent.py), which the control plane serves byte for byte from the main repo ([check it](https://github.com/getvlana/verify)).

## 1. One line, on any Linux server

```sh
curl -fsSL https://go.vlana.app/install.sh | sudo bash -s <TOKEN>
```

Port 443 taken by a web server? `curl -fsSL https://go.vlana.app/install.sh | sudo PORT=8443 bash -s <TOKEN>`

## 2. Docker

```sh
docker run -d --name vlana-node --network host --restart unless-stopped \
  -e TOKEN=<TOKEN> -e PORT=443 -v vlana:/etc/vlana ghcr.io/getvlana/node
```

or with [`docker-compose.yml`](docker-compose.yml): `TOKEN=<TOKEN> docker compose up -d`

The volume keeps the node's keys and id. Keep it, and the node survives image updates and restarts as the same node.

## 3. No SSH at all: cloud-init

Create a server and paste [`cloud-init.yaml`](cloud-init.yaml) as user data, with your token in place of `TOKEN`. The node installs itself on first boot.

| provider | where to paste |
|---|---|
| Hetzner Cloud | Create server → **Cloud config** |
| DigitalOcean | Create Droplet → Advanced options → **Add initialization scripts** |
| Vultr | Deploy → **Cloud-Init User-Data** |

## Then

Checkers test the node through a real tunnel every few minutes. The first pass makes it live, usually within 15 minutes. Watch it in **Nodes** on go.vlana.app.

How much it earns depends on fees and on where it is: rare countries earn more, home internet lines earn ×1.5. A node gets paid for an hour if it passed 95% of at least 6 checks in that hour. Details: [payouts](https://github.com/getvlana/vlana#payouts).

## Settings

| env | default | |
|---|---|---|
| `TOKEN` | | enroll token, first start only |
| `PORT` | `443` | TCP port the node listens on |
| `SNI` | `dl.google.com` | site REALITY borrows its TLS handshake from. Pick one near your server that supports TLS 1.3 and HTTP/2 |
| `VLANA_SERVER` | `https://go.vlana.app` | control plane, for self-hosted deployments |

## Trouble

| symptom | fix |
|---|---|
| stays *pending* | the port must be reachable from outside. Open it in the provider's firewall too, not only `ufw` |
| `port 443 is busy` | something else listens there (nginx, caddy). Use `PORT=8443` |
| goes offline at night | home line? Check the router keeps the port forward and the IP didn't change. A new IP is picked up on the next check-in, within a minute |

Logs: `journalctl -u vlana-agent -f`, or `docker logs -f vlana-node`.

## Remove

```sh
curl -fsSL https://raw.githubusercontent.com/getvlana/node/main/uninstall.sh | sudo sh            # agent + config, xray stopped
curl -fsSL https://raw.githubusercontent.com/getvlana/node/main/uninstall.sh | sudo sh -s --xray  # and xray too
```

Then remove the node in the app so it leaves the list.

## License

AGPL-3.0
