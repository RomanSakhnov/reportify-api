# Kamal Setup Summary

## 📋 Configuration Overview

Your Reportify API is now configured for deployment using Kamal to your dedicated server.

### 🌐 Deployment Target

- **Server**: rs-development.net
- **Domain**: reportify.rs-development.net
- **SSH User**: rs-dev
- **SSH Port**: 2121

### 🔌 Port Configuration

All ports have been customized to avoid conflicts:

| Service       | Host Port | Container Port | Purpose                   |
| ------------- | --------- | -------------- | ------------------------- |
| Rails App     | 3002      | 3000           | Main application          |
| Traefik HTTPS | 8443      | 443            | Secure web traffic        |
| Traefik HTTP  | 8080      | 80             | HTTP (redirects to HTTPS) |
| PostgreSQL    | 5433      | 5432           | Database                  |
| Redis         | 6380      | 6379           | Cache & job queue         |

**Access URLs:**

- HTTPS: `https://reportify.rs-development.net:8443`
- HTTP: `http://reportify.rs-development.net:8080` (redirects)

### 📁 Files Created/Modified

#### Configuration Files

- ✅ `config/deploy.production.yml` - Main Kamal configuration
- ✅ `.kamal/secrets` - Environment variable loader
- ✅ `Dockerfile` - Multi-stage Docker build
- ✅ `bin/docker-entrypoint` - Container startup script
- ✅ `.dockerignore` - Docker build exclusions
- ✅ `.env.production.example` - Production environment template

#### Scripts

- ✅ `bin/deploy.production` - Updated for new service name and ports
- ✅ `bin/check-deployment` - Pre-deployment validation script

#### Documentation

- ✅ `QUICKSTART.md` - Quick start guide
- ✅ `DEPLOYMENT.md` - Complete deployment guide
- ✅ `README.md` - Updated with deployment section
- ✅ `KAMAL_SETUP_SUMMARY.md` - This file

#### Dependencies

- ✅ `Gemfile` - Added kamal gem to development group

### 🚀 Deployment Flow

```
1. bin/check-deployment
   └─> Validates prerequisites

2. bin/kamal setup (first time only)
   └─> Sets up Docker, PostgreSQL, Redis

3. bin/deploy.production
   ├─> Cleans up old containers
   ├─> Stops services on conflicting ports
   └─> Runs: kamal deploy
       ├─> Builds Docker image
       ├─> Pushes to registry
       ├─> Deploys to server
       ├─> Runs migrations
       └─> Starts application
```

### 🎯 Services Deployed

#### Main Application

- **Image**: reportify-api
- **Service Name**: reportify-api
- **Health Check**: `/up` endpoint
- **Environment**: production

#### Accessories (Automatic)

1. **PostgreSQL 15**
   - Database: reportify_production
   - Volume: reportify_postgres_data
2. **Redis 7**
   - Volume: reportify_redis_data
3. **Sidekiq**
   - Uses same image as main app
   - Processes background jobs

#### Proxy (Traefik)

- Auto SSL/TLS with Let's Encrypt
- HTTP to HTTPS redirect
- Routes traffic to reportify.rs-development.net

### 🔐 Required Secrets

Create `.env.production` with these values:

```env
# Rails
RAILS_MASTER_KEY=<your-master-key>
RAILS_ENV=production

# JWT
JWT_SECRET_KEY=<long-random-string>

# Database
DB_HOST=localhost
DB_USERNAME=reportify_user
DB_PASSWORD=<secure-password>

# Redis
REDIS_URL=redis://localhost:6380/0

# Docker Registry (if using private)
DOCKER_REGISTRY_USERNAME=<username>
DOCKER_REGISTRY_PASSWORD=<password>
```

### ✅ Next Steps

1. **Install Kamal** (if not already):

   ```bash
   gem install kamal
   # Or: bundle install (kamal is in Gemfile)
   ```

2. **Configure Secrets**:

   ```bash
   cp .env.production.example .env.production
   # Edit .env.production with real values
   ```

3. **Get Rails Master Key**:
   - Use existing: `cat config/master.key`
   - Or generate new: `rails credentials:edit`

4. **Run Pre-deployment Check**:

   ```bash
   bin/check-deployment
   ```

5. **Initial Setup** (first time):

   ```bash
   bin/kamal setup -c config/deploy.production.yml
   ```

6. **Deploy**:
   ```bash
   bin/deploy.production
   ```

### 🔧 Customization Options

#### Change Ports

Edit `config/deploy.production.yml`:

```yaml
servers:
  web:
    options:
      publish:
        - "YOUR_PORT:3000"

proxy:
  http_port: YOUR_HTTP_PORT
  https_port: YOUR_HTTPS_PORT

accessories:
  db:
    port: YOUR_DB_PORT
  redis:
    port: YOUR_REDIS_PORT
```

Then update `bin/deploy.production` to match the new ports in cleanup section.

#### Frontend Integration

Your frontend server should proxy to the API:

```nginx
# Nginx example
location /api/ {
    proxy_pass http://rs-development.net:3002;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

### 📊 Monitoring & Management

```bash
# View logs
bin/kamal app logs --follow -c config/deploy.production.yml

# Check status
bin/kamal app details -c config/deploy.production.yml

# Rails console
bin/kamal console -c config/deploy.production.yml

# SSH into container
bin/kamal shell -c config/deploy.production.yml

# Run migrations
bin/kamal app exec "bin/rails db:migrate" -c config/deploy.production.yml

# Restart
bin/kamal app boot -c config/deploy.production.yml

# Rollback
bin/kamal app rollback -c config/deploy.production.yml
```

### 🆘 Troubleshooting

| Issue                  | Solution                                                                                                 |
| ---------------------- | -------------------------------------------------------------------------------------------------------- |
| SSH connection fails   | Check: `ssh -p 2121 rs-dev@rs-development.net`<br>Add key: `ssh-add ~/.ssh/your_key`                     |
| Port already in use    | `bin/deploy.production` auto-cleans, or manually:<br>`ssh -p 2121 rs-dev@rs-development.net "docker ps"` |
| Database won't connect | Check `DB_HOST=localhost` in environment<br>Verify: `bin/kamal accessory details db`                     |
| App won't start        | Check logs: `bin/kamal app logs`<br>Verify env: `bin/kamal app exec "env \| grep RAILS"`                 |
| SSL certificate issues | Ensure DNS points to server<br>Traefik will auto-request Let's Encrypt cert                              |

### 📚 Additional Resources

- [Kamal Documentation](https://kamal-deploy.org/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Rails Docker Guide](https://guides.rubyonrails.org/docker.html)

---

## Summary

✅ **Kamal configured for deployment to rs-development.net**
✅ **Custom ports configured to avoid conflicts (API: 3002)**
✅ **PostgreSQL, Redis, and Sidekiq automatically managed**
✅ **Direct API access (no proxy) - frontend handles HTTPS**
✅ **Health checks and rollback support**
✅ **Pre-deployment validation script included**

**Ready to deploy!** Run `bin/check-deployment` to verify everything is set up correctly.
