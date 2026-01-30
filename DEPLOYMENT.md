# Deployment (Kamal)

The API is deployed with [Kamal](https://kamal-deploy.org/). The app listens on **host port 3002** (container port 3000).

## Prerequisites

- Kamal: `gem install kamal` (or use the gem from the Gemfile)
- Docker on the server
- SSH access (user `rs-dev`, port 2121 to rs-development.net)
- `RAILS_MASTER_KEY` in environment or in `.env.production`

## Config

- **`config/deploy.yml`** – Kamal config (service, servers, port 3002:3000, env)
- **`.kamal/secrets`** – Exports secrets for the app (e.g. `RAILS_MASTER_KEY`). Copy from `.kamal/secrets.example` and set real values. Do not commit `.kamal/secrets`.

## Deploy

```bash
# First time: setup server (Docker, etc.)
kamal setup

# Deploy app (builds image, pushes, runs on server)
bin/deploy
# or: kamal deploy
```

After deploy, the API is available at `http://rs-development.net:3002`.

## Useful commands

```bash
kamal app logs --follow
kamal app exec --interactive --reuse "bin/rails console"
kamal app details
```

## Adding database / Redis / Sidekiq

The default `config/deploy.yml` only runs the web app. To add PostgreSQL, Redis, or Sidekiq, define them under `accessories` in `config/deploy.yml` and set the matching env vars (e.g. `DB_HOST`, `REDIS_URL`) in `.kamal/secrets` and in the app’s `env.secret` in the deploy config.
