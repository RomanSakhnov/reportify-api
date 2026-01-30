# Reportify API - Deployment Summary

## Overview

This API is set up for direct access without a reverse proxy. The idea is simple: your frontend server handles HTTPS and SSL certificates, then proxies API requests to this backend.

## Access Information

API Endpoint: `http://rs-development.net:3002`  
SSH Access: `ssh -p 2121 rs-dev@rs-development.net`

## How it Works

```
User → Frontend Server (HTTPS) → API Server (HTTP:3002) → Database/Redis
```

Your frontend server serves the application with HTTPS and forwards API calls to port 3002. The API itself doesn't need to worry about SSL—that's all handled upstream.

## Quick Commands

Deploy the app:

```bash
bin/deploy
```

Watch the logs:

```bash
kamal app logs --follow -c config/deploy.yml
```

Check if everything's running:

```bash
kamal app details -c config/deploy.yml
```

Open a Rails console:

```bash
kamal console -c config/deploy.yml
```

Run database migrations:

```bash
kamal app exec "bin/rails db:migrate" -c config/deploy.yml
```

Restart the app:

```bash
kamal app boot -c config/deploy.yml
```

## Ports

| Service    | Port | Purpose                   |
| ---------- | ---- | ------------------------- |
| API        | 3002 | Main application endpoint |
| PostgreSQL | 5433 | Database (internal)       |
| Redis      | 6380 | Cache & jobs (internal)   |
| SSH        | 2121 | Server access             |

## Key Files

`config/deploy.yml` - Main Kamal configuration  
`.env.production` - Production secrets (don't commit this!)  
`Dockerfile` - Container image definition  
`bin/deploy` - Deployment script with cleanup

## Security Notes

The frontend handles HTTPS and SSL certificates. The API just uses plain HTTP since it's sitting behind your frontend server. Authentication works with JWT tokens, and CORS is configured in `config/initializers/cors.rb`.

## Frontend Integration

Point your frontend to `http://rs-development.net:3002`. Here's a basic nginx example:

```nginx
location /api/ {
    proxy_pass http://rs-development.net:3002;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Check [FRONTEND_INTEGRATION.md](FRONTEND_INTEGRATION.md) for more examples with different stacks.

## More Documentation

[QUICKSTART.md](QUICKSTART.md) - Get up and running quickly  
[DEPLOYMENT.md](DEPLOYMENT.md) - Deep dive into deployment  
[FRONTEND_INTEGRATION.md](FRONTEND_INTEGRATION.md) - Connect your frontend  
[.kamal-commands.md](.kamal-commands.md) - All available commands  
[ARCHITECTURE.md](ARCHITECTURE.md) - How everything fits together

## Before You Deploy

Make sure you've:

- Configured `.env.production` with your secrets
- Verified SSH access works
- Set up your frontend proxy
- Updated CORS to allow your frontend domain

First time: `kamal setup`  
After that: `bin/deploy`

## Common Issues

**CORS errors?** Add your frontend domain to `config/initializers/cors.rb`

**Connection refused?** Check that port 3002 isn't blocked by a firewall

**502 errors from frontend?** The API might not be running—check with `kamal app details`

## Health Checks

Test the API directly:

```bash
curl http://rs-development.net:3002/up
```

Or through your frontend:

```bash
curl https://your-frontend.com/api/up
```

## Next Steps

1. Set up `.env.production` with your secrets
2. Run `bin/check-deployment` to verify everything
3. Deploy with `kamal setup` (first time) or `bin/deploy`
4. Configure your frontend proxy
5. Update CORS settings
6. Test the integration

---

Need help? Check the documentation files above.
