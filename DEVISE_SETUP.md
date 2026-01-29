# Devise JWT Setup Instructions

## What Changed

We've switched from custom JWT authentication to **Devise + Devise-JWT**, which is a more robust and widely-used solution.

## Setup Steps

### 1. Install Dependencies

```bash
bundle install
```

### 2. Reset and Migrate Database

Since we changed the User model structure, you need to reset the database:

```bash
rails db:drop
rails db:create
rails db:migrate
rails db:seed
```

### 3. Start the Server

```bash
rails server
```

## New API Endpoints

### Login

```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "user": {
    "email": "admin@reportify.com",
    "password": "password123"
  }
}
```

**Response:**

- JWT token in `Authorization` header
- User data in response body

### Logout

```bash
DELETE /api/v1/auth/logout
Authorization: Bearer YOUR_JWT_TOKEN
```

### Get Current User

```bash
GET /api/v1/auth/me
Authorization: Bearer YOUR_JWT_TOKEN
```

### Signup (Register)

```bash
POST /api/v1/auth/signup
Content-Type: application/json

{
  "user": {
    "email": "newuser@example.com",
    "password": "password123",
    "name": "New User"
  }
}
```

## Key Differences

### Request Format

- **Old**: `{ "email": "...", "password": "..." }`
- **New**: `{ "user": { "email": "...", "password": "..." } }`

### Token Location

- **Old**: Token in response body
- **New**: Token in `Authorization` response header

### Authentication

All controllers now use Devise's `authenticate_user!` and `current_user` methods automatically.

## Testing with cURL

```bash
# Login and capture token
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"admin@reportify.com","password":"password123"}}' \
  -i | grep -i authorization

# Use token in subsequent requests
curl http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Benefits of Devise JWT

1. ✅ Industry-standard authentication
2. ✅ Built-in token revocation
3. ✅ Password recovery support
4. ✅ Automatic token refresh
5. ✅ Better security practices
6. ✅ Extensive documentation and community support
