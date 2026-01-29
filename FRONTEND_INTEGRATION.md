# Frontend Integration

The API is set up for direct access—no reverse proxy needed on the API side. Your frontend server handles SSL and proxies requests to the backend.

## API Endpoint

Base URL: `http://rs-development.net:3002`

## Setting Up Your Frontend Server

### Nginx

Add this to your nginx config:

```nginx
# Proxy API requests
location /api/ {
    proxy_pass http://rs-development.net:3002;
    proxy_http_version 1.1;

    # Headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;

    # WebSocket support (if needed)
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    # Timeouts
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
}

# Health check endpoint
location /api/up {
    proxy_pass http://rs-development.net:3002/up;
    proxy_set_header Host $host;
    access_log off;
}
```

### Apache

If you're using Apache with mod_proxy:

```apache
<VirtualHost *:443>
    ServerName your-frontend-domain.com

    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /path/to/cert.pem
    SSLCertificateKeyFile /path/to/key.pem

    # Proxy API requests
    ProxyPreserveHost On
    ProxyPass /api/ http://rs-development.net:3002/api/
    ProxyPassReverse /api/ http://rs-development.net:3002/api/

    # Set headers
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-Port "443"
</VirtualHost>
```

### Node.js / Express

Running Node.js with Express? Use http-proxy-middleware:

```javascript
const express = require("express");
const { createProxyMiddleware } = require("http-proxy-middleware");

const app = express();

// Proxy API requests
app.use(
  "/api",
  createProxyMiddleware({
    target: "http://rs-development.net:3002",
    changeOrigin: true,
    onProxyReq: (proxyReq, req, res) => {
      // Add custom headers
      proxyReq.setHeader("X-Forwarded-Proto", req.protocol);
      proxyReq.setHeader("X-Forwarded-Host", req.hostname);
    },
  }),
);

app.listen(3000);
```

### Next.js

Add this to your `next.config.js`:

```javascript
module.exports = {
  async rewrites() {
    return [
      {
        source: "/api/:path*",
        destination: "http://rs-development.net:3002/api/:path*",
      },
    ];
  },
};
```

## CORS Configuration

CORS is already configured in `config/application.rb` to allow:

- `rs-test.net`
- `reportify.rs-development.net`
- Local development servers

If you need to add more domains, edit `config/application.rb`:

```ruby
config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'rs-test.net',
            'www.rs-test.net',
            'reportify.rs-development.net',
            'your-new-domain.com'  # Add your domain here

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: true,
             expose: ['Authorization']
  end
end
```

After changing CORS settings, redeploy:

```bash
bin/deploy.production
```

## API Endpoints

All API endpoints are under `/api/v1/`:

### Authentication

```
POST   /api/v1/auth/login      - User login
POST   /api/v1/auth/signup     - User registration
DELETE /api/v1/auth/logout     - User logout
GET    /api/v1/auth/me         - Get current user
```

### Users

```
GET    /api/v1/users           - List users
GET    /api/v1/users/:id       - Get user
POST   /api/v1/users           - Create user
PUT    /api/v1/users/:id       - Update user
DELETE /api/v1/users/:id       - Delete user
```

### Items

```
GET    /api/v1/items           - List items
GET    /api/v1/items/:id       - Get item
POST   /api/v1/items           - Create item
PUT    /api/v1/items/:id       - Update item
DELETE /api/v1/items/:id       - Delete item
```

### Reports

```
GET    /api/v1/reports/dashboard - Dashboard data
GET    /api/v1/reports/metrics   - Time-series metrics
GET    /api/v1/reports/trends    - Trend analysis
```

### Health Checks

```
GET    /up                     - Health check (for monitoring)
GET    /health                 - Alternative health endpoint
```

## Authentication

The API uses JWT tokens for authentication. Here's how it works:

### Login Flow

First, send a login request:

```javascript
const response = await fetch(
  "http://rs-development.net:3002/api/v1/auth/login",
  {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      email: "user@example.com",
      password: "password123",
    }),
  },
);

const data = await response.json();
const token = response.headers.get("Authorization");
```

Store the token somewhere (localStorage, sessionStorage, or a cookie):

```javascript
localStorage.setItem("authToken", token);
```

Then include it in all future requests:

```javascript
const response = await fetch("http://rs-development.net:3002/api/v1/items", {
  headers: {
    Authorization: localStorage.getItem("authToken"),
    "Content-Type": "application/json",
  },
});
```

## Frontend Integration Examples

### React with Fetch

Here's a simple API wrapper for React:

```javascript
// api.js
const API_BASE = "http://rs-development.net:3002";

async function apiRequest(endpoint, options = {}) {
  const token = localStorage.getItem("authToken");

  const config = {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...(token && { Authorization: token }),
      ...options.headers,
    },
  };

  const response = await fetch(`${API_BASE}${endpoint}`, config);

  // Save token if present in response
  const authHeader = response.headers.get("Authorization");
  if (authHeader) {
    localStorage.setItem("authToken", authHeader);
  }

  return response.json();
}

// Use it like this:
async function login(email, password) {
  return apiRequest("/api/v1/auth/login", {
    method: "POST",
    body: JSON.stringify({ email, password }),
  });
}

async function getItems() {
  return apiRequest("/api/v1/items");
}
```

### Vue.js with Axios

For Vue projects using Axios:

```javascript
// plugins/axios.js
import axios from "axios";

const api = axios.create({
  baseURL: "http://rs-development.net:3002",
  headers: {
    "Content-Type": "application/json",
  },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem("authToken");
  if (token) {
    config.headers.Authorization = token;
  }
  return config;
});

// Response interceptor - save token
api.interceptors.response.use((response) => {
  const authHeader = response.headers.authorization;
  if (authHeader) {
    localStorage.setItem("authToken", authHeader);
  }
  return response;
});

export default api;

// Use it in your components:
import api from "./plugins/axios";

async function login(email, password) {
  const response = await api.post("/api/v1/auth/login", { email, password });
  return response.data;
}
```

## Testing Everything

Test the API directly first:

```bash
# Health check
curl http://rs-development.net:3002/up

# Try logging in
curl -X POST http://rs-development.net:3002/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}' \
  -i

# Use the token for authenticated requests
curl http://rs-development.net:3002/api/v1/items \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

Once your frontend proxy is set up, test through it:

```bash
curl https://your-frontend-domain.com/api/up
curl https://your-frontend-domain.com/api/v1/items
```

## Troubleshooting

### CORS Errors

If you see CORS errors in the browser console:

1. Make sure `config/initializers/cors.rb` includes your frontend domain
2. Redeploy after changing CORS settings: `bin/deploy.production`

### 502 Bad Gateway

Getting 502 errors from nginx?

1. Check if the API is actually running: `bin/kamal app details -c config/deploy.production.yml`
2. Look at the API logs: `bin/kamal app logs -c config/deploy.production.yml`
3. Test the connection: `curl http://rs-development.net:3002/up`

### Authentication Issues

Getting 401 Unauthorized errors?

1. Make sure the JWT token is being sent in the `Authorization` header
2. Check the token format—it should be exactly what the login response gave you
3. Verify the token hasn't expired (and that `JWT_SECRET_KEY` matches on both ends)

### Connection Timeouts

Requests hanging or timing out?

1. Check if port 3002 is blocked by a firewall
2. Verify your frontend server can reach the API server
3. Try increasing timeout settings in your proxy config

## Security Tips

A few things to keep in mind:

- Always use HTTPS on your frontend server
- Configure CORS strictly—only allow your actual frontend domain
- Store JWT tokens securely (httpOnly cookies are ideal when possible)
- Add rate limiting on your frontend proxy
- Monitor your API access logs for anything suspicious
- Use environment variables for the API URL instead of hardcoding it
- Handle errors properly without exposing internal details to users

## Environment Configuration

For development, you might want to hit a local Rails server:

```javascript
const API_BASE =
  process.env.NODE_ENV === "development"
    ? "http://localhost:3000"
    : "http://rs-development.net:3002";
```

In production, use environment variables:

```javascript
const API_BASE =
  process.env.REACT_APP_API_URL || "http://rs-development.net:3002";
```

## Need More Help?

Check out the other docs:

- [DEPLOYMENT.md](DEPLOYMENT.md) - Full deployment guide
- [.kamal-commands.md](.kamal-commands.md) - All available commands
- [QUICKSTART.md](QUICKSTART.md) - Get started quickly
