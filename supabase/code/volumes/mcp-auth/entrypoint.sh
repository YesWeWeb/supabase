#!/bin/sh
# Generates a Caddyfile that basic-auth-protects postgres-mcp, hashing the
# plaintext password (MCP_AUTH_PASS) at startup so no hash needs to live in env.
set -e

if [ -z "$MCP_AUTH_USER" ] || [ -z "$MCP_AUTH_PASS" ]; then
  echo "mcp-auth: MCP_AUTH_USER and MCP_AUTH_PASS must be set" >&2
  exit 1
fi

HASH=$(caddy hash-password --plaintext "$MCP_AUTH_PASS")

cat > /etc/caddy/Caddyfile <<EOF
{
	admin off
	auto_https off
}

:8080 {
	basic_auth {
		$MCP_AUTH_USER $HASH
	}
	reverse_proxy postgres-mcp:8000 {
		flush_interval -1
	}
}
EOF

exec caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
