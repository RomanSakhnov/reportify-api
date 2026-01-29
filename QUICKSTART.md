# Quick Start

## Get Your API Running

Before you start, make sure you have:

- Kamal installed (`gem install kamal`)
- Docker running on your server
- SSH access set up (port 2121, user rs-dev)
- Your SSH key added (`ssh-add ~/.ssh/your_key`)

### Configure Environment Variables

Copy the example environment file and fill in your values:

```bash
cp .env.production.example .env.production
nano .env.production
```

You'll need:

- `RAILS_MASTER_KEY` - grab this from `config/master.key`
- `JWT_SECRET_KEY` - a long random string for JWT tokens
- `DB_PASSWORD` - something secure for PostgreSQL
- Docker registry credentials (if you're using a private registry)

### Initial Setup (First Time)

```bash
# This sets up Docker, Traefik, PostgreSQL, and Redis on your server
bin/kamal setup -c config/deploy.production.yml
```

### Step 3: Deploy

```bash
# Deploy using the custom script (includes cleanup)
bin/deploy.production

# Or deploy directly with Kamal
bin/kamal deploy -c config/deploy.production.yml
```

### Step 4: Access Your Application

Your app will be available at:

- **HTTPS**: `https://reportify.rs-development.net:8443`
- **HTTP**: `http://reportify.rs-development.net:8080` (redirects to HTTPS)

## 📦 What Gets Deployed

### Services

- **Rails App** (reportify-api)
  - Port: 3002 → 3000
  - URL: reportify.rs-development.net

### Accessories

- **PostgreSQL 15**
  - Port: 5433 → 5432
  - Database: reportify_production
- **Redis 7**
  - Port: 6380 → 6379
- **Sidekiq**
  - Background job processing

### Proxy (Traefik)

- HTTP Port: 8080
- HTTPS Port: 8443
- Auto SSL/TLS with Let's Encrypt

## 🔧 Common Commands

```bash
# View logs
bin/kamal app logs --follow -c config/deploy.production.yml

# Rails console
bin/kamal console -c config/deploy.production.yml

# SSH into container
bin/kamal shell -c config/deploy.production.yml

# Run migrations
bin/kamal app exec "bin/rails db:migrate" -c config/deploy.production.yml

# Restart app
bin/kamal app boot -c config/deploy.production.yml

# Check status
bin/kamal app details -c config/deploy.production.yml

# Rollback
bin/kamal app rollback -c config/deploy.production.yml
```

## 🔐 Security Notes

⚠️ **Never commit these files with real credentials:**

- `.env.production`
- `.kamal/secrets`
- `config/master.key`

These are already in `.gitignore` for protection.

## 🆘 Troubleshooting

### Can't connect to server

```bash
# Test SSH connection
ssh -p 2121 rs-dev@rs-development.net

# If fails, add your SSH key
ssh-add ~/.ssh/your_key
```

### Port conflicts

The `bin/deploy.production` script automatically cleans up old containers.
If issues persist, manually stop containers:

```bash
ssh -p 2121 rs-dev@rs-development.net "docker ps"
ssh -p 2121 rs-dev@rs-development.net "docker stop <container_id>"
```

### Database issues

```bash
# Check PostgreSQL status
bin/kamal accessory details db -c config/deploy.production.yml

# View PostgreSQL logs
bin/kamal accessory logs db -c config/deploy.production.yml
```

### App won't start

```bash
# Check application logs
bin/kamal app logs -c config/deploy.production.yml

# Verify environment variables
bin/kamal app exec "env | grep RAILS" -c config/deploy.production.yml
```

## 📚 Full Documentation

For detailed information, see [DEPLOYMENT.md](DEPLOYMENT.md)

## 🎯 Custom Port Configuration

Current ports (configured to avoid conflicts):

- App: 3002 → 3000
- Traefik HTTP: 8080
- Traefik HTTPS: 8443
- PostgreSQL: 5433 → 5432
- Redis: 6380 → 6379

To change ports, edit `config/deploy.production.yml` and update the `bin/deploy.production` script accordingly.
