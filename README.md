# App Repository Template

This directory is a template for application repositories that deploy into the
separate `infra-server` repository model.

Use it when you want a new app repository to:

- build Docker images on GitHub Actions
- publish images to GHCR
- upload its own production Compose file to the VPS
- restart only its own stack

without embedding shared server infrastructure into the app repository.

## Expected architecture

- app repository owns source code, tests, Dockerfiles, image publishing, and `docker-compose.prod.yml`
- `infra-server` repository owns only Caddy, Homarr, Portainer, Uptime Kuma, and domain routes

## How deploy works

1. push to `main`
2. GitHub Actions runs `make ci`
3. GitHub Actions builds and pushes Docker images to GHCR
4. GitHub Actions connects to the VPS by SSH
5. GitHub Actions uploads `deploy/docker-compose.prod.yml` to the VPS
6. GitHub Actions runs `docker compose pull && docker compose up -d` for this app only

## Files included

- `.github/workflows/publish-and-deploy.yml`
- `Makefile`
- `scripts/set-gh-secrets.sh`
- `.env.example`
- `deploy/docker-compose.prod.yml`

## Required GitHub secrets

- `GHCR_USERNAME`
- `GHCR_TOKEN`
- `VPS_HOST`
- `VPS_USER`
- `VPS_PORT`
- `VPS_SSH_KEY`
- `VPS_APPS_DIR`
- `SERVICE_NAME`

## Required GitHub variables

- `IMAGE_NAMESPACE`

Example:

- `IMAGE_NAMESPACE=ghcr.io/ismakv`

## Example image names

For repository `cool-app`:

- `ghcr.io/ismakv/cool-app-backend:<sha>`
- `ghcr.io/ismakv/cool-app-frontend:<sha>`

## VPS layout

This template expects each app to live in its own server folder:

- `/opt/apps/my-app/docker-compose.prod.yml`
- `/opt/apps/my-app/.deploy.env`

## First-time setup for a new app

1. Create a new repository from this template.
2. Add your app code and Dockerfiles.
3. Adjust `deploy/docker-compose.prod.yml`.
4. Add one Caddy route in `infra-server`, for example:

```caddy
my-app.example.com {
  reverse_proxy http://my-app-web:80
}
```

5. Add the DNS `A` record for the subdomain.
6. Push to `main`.

This template provides the deploy contract between a new app repository and the shared VPS infrastructure.
