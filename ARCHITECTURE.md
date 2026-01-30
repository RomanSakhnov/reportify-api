# Deployment Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Internet                                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                ┌────────────────────────────────┐
                │  reportify.rs-development.net  │
                │         (Your Server)          │
                └────────────────────────────────┘
                             │
                             ▼
┌────────────────────────────────────────────────────────────────┐
│                      Traefik Proxy                             │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  HTTP  :8080  ──────────────────────┐                    │  │
│  │  HTTPS :8443  ──────────────────────┤                    │  │
│  │                                     │                    │  │
│  │  • Auto SSL/TLS (Let's Encrypt)     │                    │  │
│  │  • HTTP → HTTPS redirect            │                    │  │
│  │  • Host routing                     │                    │  │
│  └─────────────────────────────────────┼────────────────────┘  │
└────────────────────────────────────────┼───────────────────────┘
                                         │
                                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Containers                            │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐     │
│  │  Reportify API (Rails App)                             │     │
│  │  ┌──────────────────────────────────────────────────┐  │     │
│  │  │  Port: 3002:3000                                 │  │     │
│  │  │  Service: reportify-api                          │  │     │
│  │  │  Environment: production                         │  │     │
│  │  │  Health Check: /up                               │  │     │
│  │  └──────────────────────────────────────────────────┘  │     │
│  │          │                    │                        │     │
│  │          │ ┌──────────────────┼─────────┐              │     │
│  │          │ │                  │         │              │     │
│  └──────────┼─┼──────────────────┼─────────┼──────────────┘     │
│             │ │                  │         │                    │
│  ┌──────────▼─▼───────┐  ┌────────▼─────┐  │                    │
│  │   PostgreSQL 15    │  │   Redis 7    │  │                    │
│  │  ┌──────────────┐  │  │  ┌────────┐  │  │                    │
│  │  │ Port: 5433   │  │  │  │ Port:  │  │  │                    │
│  │  │      :5432   │  │  │  │  6380  │  │  │                    │
│  │  │              │  │  │  │  :6379 │  │  │                    │
│  │  │ DB: reportify│  │  │  │        │  │  │                    │
│  │  │  _production │  │  │  │ Cache  │  │  │                    │
│  │  │              │  │  │  │ & Jobs │  │  │                    │
│  │  │ Volume:      │  │  │  │ Queue  │  │  │                    │
│  │  │ postgres_data│  │  │  │        │  │  │                    │
│  │  └──────────────┘  │  │  │ Volume:│  │  │                    │
│  └────────────────────┘  │  │ redis_ │  │  │                    │
│                          │  │ data   │  │  │                    │
│                          │  └────────┘  │  │                    │
│                          └──────────────┘  │                    │
│                                            │                    │
│  ┌─────────────────────────────────────────▼─────────────────┐  │
│  │  Sidekiq Worker                                           │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │  Uses: reportify-api image                          │  │  │
│  │  │  Processes: Background jobs                         │  │  │
│  │  │  Connects to: Redis, PostgreSQL                     │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Port Mapping

### External Access

```
Internet → reportify.rs-development.net:8443 (HTTPS)
         → reportify.rs-development.net:8080 (HTTP, redirects to HTTPS)
```

### Internal Services

```
Traefik Proxy      :8080  → :80   (HTTP)
                   :8443  → :443  (HTTPS)

Rails App          :3002  → :3000
PostgreSQL         :5433  → :5432
Redis              :6380  → :6379

SSH Access         :2121
```

## Data Flow

### 1. User Request

```
User Browser
   ↓ HTTPS
Traefik Proxy (8443)
   ↓ HTTP
Rails App (3000)
   ↓
PostgreSQL / Redis
```

### 2. Background Job

```
Rails App
   ↓ Enqueue
Redis Queue
   ↓ Process
Sidekiq Worker
   ↓ Save Results
PostgreSQL
```

### 3. Authentication Flow

```
User → Login Request
   ↓
Rails App → Validate Credentials
   ↓
PostgreSQL → User Data
   ↓
Rails App → Generate JWT Token
   ↓
Response → JWT Token
```

## Deployment Process

```
Local Machine               Server (rs-development.net)
─────────────              ────────────────────────────

1. bin/deploy
   │
   ├─ Cleanup old containers
   │  └─ SSH → Stop/Remove old containers
   │
   └─ kamal deploy
      │
      ├─ 2. Build Docker Image
      │     └─ docker build
      │
      ├─ 3. Push to Registry
      │     └─ docker push
      │
      └─ 4. Deploy to Server ──────────┐
                                       │
                          ┌────────────▼────────────┐
                          │  Pull Image             │
                          │  Stop Old Container     │
                          │  Start New Container    │
                          │  Run Migrations         │
                          │  Health Check           │
                          │  Switch Traffic         │
                          └─────────────────────────┘
```

## Security Layers

```
┌──────────────────────────────────────────────┐
│  1. SSL/TLS (Your Frontend Server)          │
│     • Encrypted HTTPS traffic                │
│     • SSL certificate management             │
└──────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│  2. Frontend Reverse Proxy                   │
│     • Request filtering                      │
│     • Rate limiting (optional)               │
│     • CORS handling                          │
└──────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│  3. Rails API Application                    │
│     • JWT Authentication                     │
│     • Authorization checks                   │
│     • Input validation (dry-validation)      │
└──────────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────────┐
│  4. Database                                 │
│     • Isolated Docker network                │
│     • Password protection                    │
│     • Encrypted connections                  │
└──────────────────────────────────────────────┘
```

## Resource Management

### Volumes (Persistent Data)

```
reportify_postgres_data   → PostgreSQL database files
reportify_redis_data      → Redis persistence
reportify_storage         → Rails uploaded files
```

### Networks

```
kamal              → Container communication
traefik           → Proxy network
```

### Environment Variables Flow

```
.env.production (local)
      ↓
.kamal/secrets (script)
      ↓
Kamal Deploy
      ↓
Docker Containers (environment)
```

## Scaling Possibilities

### Horizontal Scaling

```
┌─────────────────┐
│  Traefik Proxy  │
└────────┬────────┘
         │
    ┌────┴────┐
    ↓         ↓
┌──────┐  ┌──────┐
│ App1 │  │ App2 │  ← Add more containers
└──────┘  └──────┘
    │         │
    └────┬────┘
         ↓
  ┌────────────┐
  │ PostgreSQL │
  └────────────┘
```

### Vertical Scaling

```yaml
# In deploy.yml
servers:
  web:
    options:
      memory: 2g
      cpus: 2
```

## Monitoring Points

```
Application Level:
  • /up - Health check endpoint
  • /health - Custom health endpoint
  • Rails logs → docker logs

Infrastructure Level:
  • Docker stats - Resource usage
  • Traefik logs - Proxy activity
  • PostgreSQL logs - Database queries
  • Redis logs - Cache/queue activity
  • Sidekiq logs - Background jobs

Commands:
  kamal app logs
  kamal accessory logs db
  kamal accessory logs redis
  kamal accessory logs sidekiq
```

## Backup Strategy

```
┌─────────────────────────────────────────┐
│  PostgreSQL                             │
│  ├─ Regular dumps                       │
│  │  └─ pg_dump reportify_production     │
│  └─ Volume snapshots                    │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Redis                                  │
│  └─ RDB persistence (automatic)         │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Application Code                       │
│  └─ Git repository                      │
└─────────────────────────────────────────┘
```

## Rollback Process

```
Issue Detected
      ↓
kamal app rollback
      ↓
Switch to Previous Image
      ↓
Health Check
      ↓
Service Restored
```

## Service Dependencies

```
Your Frontend Server
   └─ Required for: HTTPS/SSL, Routing to API

PostgreSQL
   └─ Required for: Application, Sidekiq

Redis
   └─ Required for: Application cache, Sidekiq queue

Rails API
   └─ Depends on: PostgreSQL, Redis

Sidekiq
   └─ Depends on: Redis, PostgreSQL, Rails API image
```

## Configuration Files Map

```
Project Root
│
├── config/
│   └── deploy.yml     → Kamal config
│
├── .kamal/
│   └── secrets                    → Environment loader
│
├── Dockerfile                     → Container image
├── .dockerignore                  → Build exclusions
├── bin/
│   ├── deploy          → Deployment script
│   ├── docker-entrypoint          → Container startup
│   └── check-deployment           → Pre-flight checks
│
└── .env.production               → Secrets (not in git)
```

## Network Diagram

```
┌─────────────────────────────────────────────────────────┐
│  Docker Host (rs-development.net)                       │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │  kamal network                                  │    │
│  │  ┌──────┐  ┌──────┐  ┌─────┐  ┌─────────┐     │    │
│  │  │ App  │──│  DB  │──│Redis│──│ Sidekiq │     │    │
│  │  │:3000 │  │:5432 │  │:6379│  │         │     │    │
│  │  └───┬──┘  └──────┘  └─────┘  └─────────┘     │    │
│  │      │                                          │    │
│  │      │ Port Mapping                             │    │
│  │      └───► Host :3002                           │    │
│  └────────────┬──────────────────────────────────┘     │
│               │                                         │
│          External Access                                │
│          (from frontend server)                         │
│               ▲                                         │
└───────────────┼─────────────────────────────────────────┘
                │
        Your Frontend Server
```

---

**Quick Reference**: For day-to-day operations, see [.kamal-commands.md](.kamal-commands.md)
