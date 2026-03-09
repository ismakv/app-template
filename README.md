# App Repository Template

This directory is a template for application repositories that deploy into the
separate `infra-server` repository model.

Use it when you want a new app repository to:

- build Docker images on GitHub Actions
- publish images to GHCR
- trigger a VPS update for its stack

without embedding full server infrastructure into the app repository.

## Expected architecture

- app repository owns source code, tests, Dockerfiles, image publishing
- `infra-server` repository owns Caddy, Homarr, Portainer, Uptime Kuma, and app stacks

## How deploy works

1. push to `main`
2. GitHub Actions runs `make ci`
3. GitHub Actions builds and pushes Docker images to GHCR
4. GitHub Actions connects to the VPS by SSH
5. GitHub Actions runs `docker compose pull && docker compose up -d` for this app stack inside `infra-server`

## Required conventions

- the app stack already exists on the server under `infra-server/apps/<service>`
- image tags are based on the Git commit SHA
- the app stack uses environment variables for image names and tags

## Files included

- `.github/workflows/publish-and-deploy.yml`
- `Makefile`
- `scripts/set-gh-secrets.sh`
- `.env.example`

## Required GitHub secrets

- `GHCR_USERNAME`
- `GHCR_TOKEN`
- `VPS_HOST`
- `VPS_USER`
- `VPS_PORT`
- `VPS_SSH_KEY`
- `VPS_INFRA_DIR`
- `SERVICE_NAME`

## Required GitHub variables

- `IMAGE_NAMESPACE`

Example:

- `IMAGE_NAMESPACE=ghcr.io/ismakv`

## Example image names

For repository `cool-app`:

- `ghcr.io/ismakv/cool-app-backend:<sha>`
- `ghcr.io/ismakv/cool-app-frontend:<sha>`

## Important

This template does not include application source code.

It provides the deploy contract between a new app repository and the shared VPS infrastructure.
