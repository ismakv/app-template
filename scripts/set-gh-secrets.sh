#!/usr/bin/env bash
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh CLI is not installed. Install from https://cli.github.com/" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Error: gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

if [ $# -ne 1 ]; then
  echo "Usage: $0 <owner/repo>" >&2
  echo "Example: $0 ismakv/cool-app" >&2
  exit 1
fi

REPO="$1"

required_vars=(
  GHCR_USERNAME
  GHCR_TOKEN
  VPS_HOST
  VPS_USER
  VPS_PORT
  VPS_APPS_DIR
  SERVICE_NAME
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: env var $var is required" >&2
    exit 1
  fi
done

KEY_PATH="${VPS_SSH_KEY_PATH:-$HOME/.ssh/gha_vps_deploy}"
if [ ! -f "$KEY_PATH" ]; then
  echo "Error: private key file not found: $KEY_PATH" >&2
  exit 1
fi

set_secret() {
  local name="$1"
  local value="$2"
  gh secret set "$name" -b "$value" -R "$REPO" >/dev/null
  echo "Set $name"
}

set_variable() {
  local name="$1"
  local value="$2"
  gh variable set "$name" -b "$value" -R "$REPO" >/dev/null
  echo "Set variable $name"
}

set_secret "GHCR_USERNAME" "$GHCR_USERNAME"
set_secret "GHCR_TOKEN" "$GHCR_TOKEN"
set_secret "VPS_HOST" "$VPS_HOST"
set_secret "VPS_USER" "$VPS_USER"
set_secret "VPS_PORT" "$VPS_PORT"
set_secret "VPS_APPS_DIR" "$VPS_APPS_DIR"
set_secret "SERVICE_NAME" "$SERVICE_NAME"
gh secret set "VPS_SSH_KEY" -b "$(cat "$KEY_PATH")" -R "$REPO" >/dev/null
echo "Set VPS_SSH_KEY"

if [ -n "${IMAGE_NAMESPACE:-}" ]; then
  set_variable "IMAGE_NAMESPACE" "$IMAGE_NAMESPACE"
fi

echo "Done. Secrets configured for $REPO"
