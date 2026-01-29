# Deployment Guide

## Overview

This API deploys to rs-development.net using Kamal. The ports are configured to avoid conflicts with anything else you might be running.

## Port Configuration

Here's what's running where:

- Rails app: port 3002
- PostgreSQL: port 5433
- Redis: port 6380
- SSH: port 2121

Note: There's no proxy like Traefik here. The API is accessed directly on port 3002. Your frontend server handles HTTPS and proxies to this endpoint.

## Before You Start

Make sure you have:

**Kamal installed:**

```bash
gem install kamal
```

**Docker on your server** (rs-development.net)

**SSH access set up:**

- User: rs-dev
- Port: 2121
- Add your SSH key: `ssh-add ~/.ssh/your_key`

**Environment file configured:**

Copy the example and fill in your values:

```bash
cp .env.production.example .env.production
```

You'll need:

- `RAILS_MASTER_KEY` - from `config/master.key`
- `JWT_SECRET_KEY` - for JWT token signing
- `DB_PASSWORD` - PostgreSQL password
- Docker registry credentials (if using a private one)

## Deployment Steps

### Initial Setup (First Time Only)

1. **Set up Kamal on the server**:

   ```bash
   bin/kamal setup -c config/deploy.production.yml
   ```

   This will:
   - Install Docker if needed
   - Set up Traefik proxy
   - Create necessary volumes
   - Set up PostgreSQL and Redis accessories

### Regular Deployment

1. **Deploy the application**:

   ```bash
   bin/deploy.production
   ```

   Or use Kamal directly:

   ```bash
   bin/kamal deploy -c config/deploy.production.yml
   ```

### Useful Commands

- **Check application logs**:

  ```bash
  bin/kamal app logs --follow -c config/deploy.production.yml
  ```

- **Open Rails console on server**:

  ```bash
  bin/kamal app exec --interactive --reuse "bin/rails console" -c config/deploy.production.yml
  ```

  Or using the alias:

  ```bash
  bin/kamal console -c config/deploy.production.yml
  ```

- **SSH into the container**:

  ```bash
  bin/kamal app exec --interactive --reuse "bash" -c config/deploy.production.yml
  ```

  Or using the alias:

  ```bash
  bin/kamal shell -c config/deploy.production.yml
  ```

- **Run database migrations**:

  ```bash
  bin/kamal app exec "bin/rails db:migrate" -c config/deploy.production.yml
  ```

- **Check app status**:

  ```bash
  bin/kamal app details -c config/deploy.production.yml
  ```

- **Restart the application**:

  ```bash
  bin/kamal app boot -c config/deploy.production.yml
  ```

- **Stop the application**:

  ```bash
  bin/kamal app stop -c config/deploy.production.yml
  ```

- **View Sidekiq logs**:

  ```bash
  bin/kamal accessory logs sidekiq --follow -c config/deploy.production.yml
  ```

- **Restart accessories (PostgreSQL, Redis, Sidekiq)**:
  ```bash
  bin/kamal accessory restart db -c config/deploy.production.yml
  bin/kamal accessory restart redis -c config/deploy.production.yml
  bin/kamal accessory restart sidekiq -c config/deploy.production.yml
  ```

### Rollback

If something goes wrong, you can rollback to the previous version:

```bash
bin/kamal app rollback -c config/deploy.production.yml
```

## Frontend Integration

The API doesn't have its own proxy, so your frontend server needs to handle HTTPS and proxy requests to `http://rs-development.net:3002`.

Here's a basic nginx setup:

```nginx
location /api/ {
    proxy_pass http://rs-development.net:3002;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## Troubleshooting

### Port Conflicts

The deployment script automatically cleans up old containers. If you still have port conflicts:

Check what's running:

```bash
ssh -p 2121 rs-dev@rs-development.net "docker ps"
```

Stop the offending container:

```bash
ssh -p 2121 rs-dev@rs-development.net "docker stop <container_id>"
```

### Database Issues

Check if PostgreSQL is running:

```bash
bin/kamal accessory details db -c config/deploy.production.yml
```

Look at the logs:

```bash
bin/kamal accessory logs db -c config/deploy.production.yml
```

Make sure `DB_HOST=localhost` in your `.env.production` (since the database runs on the same host).

### App Won't Start

Check the logs:

```bash
bin/kamal app logs -c config/deploy.production.yml
```

Verify environment variables:

```bash
bin/kamal app exec "env | grep RAILS" -c config/deploy.production.yml
```

Try running migrations manually:

```bash
bin/kamal app exec "bin/rails db:migrate" -c config/deploy.production.yml
```

## Changing Ports

Edit `config/deploy.production.yml` if you need different ports:

```yaml
servers:
  web:
    options:
      publish:
        - "YOUR_PORT:3000"

accessories:
  db:
    port: YOUR_DB_PORT
  redis:
    port: YOUR_REDIS_PORT
```

Don't forget to update the port numbers in `bin/deploy.production` too (in the cleanup section).

## Security Notes

Keep these safe and never commit them:

- `.env.production`
- `.kamal/secrets`
- `config/master.key`

Use strong passwords for the database and keep your `JWT_SECRET_KEY` secure.

## Accessing Your API

Once deployed, the API runs at `http://rs-development.net:3002`.

Your frontend should proxy to this endpoint and handle HTTPS.
