# Reportify API

Ruby on Rails API backend for the Reportify application. This is an API-only Rails application featuring JWT authentication, background job processing with Sidekiq, and business logic organized using dry-rb gems and service objects.

## Tech Stack

- **Ruby on Rails** 7.1+ (API-only mode)
- **PostgreSQL** - Primary database
- **Redis** - Cache and message broker for Sidekiq
- **Sidekiq** - Background job processing
- **JWT** - Token-based authentication
- **dry-rb** gems - Business logic and validation
  - dry-validation - Input validation
  - dry-struct - Type-safe data structures
  - dry-monads - Functional error handling
- **RSpec** - Testing framework
- **FactoryBot** - Test data factories
- **Faker** - Random data generation

## Architecture

### Service Objects

Business logic is organized into service objects that return Result monads (Success/Failure). This provides:

- Clear separation of concerns
- Functional error handling
- Testable business logic
- Consistent API across services

Example:

```ruby
result = Authentication::LoginService.call(email: 'user@example.com', password: 'password')

case result
when Dry::Monads::Success
  # Handle success
when Dry::Monads::Failure
  # Handle failure
end
```

### Contracts (Validation)

Input validation is handled by dry-validation contracts, providing:

- Schema validation
- Custom validation rules
- Type coercion
- Detailed error messages

### API Structure

All API endpoints are namespaced under `/api/v1/`:

- `POST /api/v1/auth/login` - User authentication
- `GET /api/v1/auth/me` - Get current user
- `GET/POST/PUT/DELETE /api/v1/users` - User management
- `GET/POST/PUT/DELETE /api/v1/items` - Item management
- `GET /api/v1/reports/dashboard` - Dashboard data
- `GET /api/v1/reports/metrics` - Time-series metrics
- `GET /api/v1/reports/trends` - Trend analysis

## Prerequisites

- Ruby 3.2+ (`ruby --version`)
- PostgreSQL 12+ (`psql --version`)
- Redis 6+ (`redis-cli --version`)
- Bundler (`gem install bundler`)

## Setup Instructions

### 1. Install Dependencies

```bash
cd reportify-api
bundle install
```

### 2. Configure Environment

Copy the example environment file and update with your settings:

```bash
cp .env.example .env
```

Edit `.env` and set your database credentials:

```env
DB_HOST=localhost
DB_USERNAME=postgres
DB_PASSWORD=postgres
REDIS_URL=redis://localhost:6379/0
JWT_SECRET_KEY=your-secret-key-change-in-production
```

### 3. Setup Database

Create and migrate the database:

```bash
rails db:create
rails db:migrate
rails db:seed
```

The seed command will create:

- Admin user: `admin@reportify.com` / `password123`
- 10 regular users with random data
- Sample items for each user
- 30 days of report data

### 4. Start Redis

Make sure Redis is running:

```bash
redis-server
```

Or if using Homebrew on macOS:

```bash
brew services start redis
```

### 5. Start Sidekiq

In a separate terminal, start the Sidekiq worker:

```bash
bundle exec sidekiq
```

### 6. Start Rails Server

```bash
rails server
# or
rails s
```

The API will be available at `http://localhost:3000`

## Development Workflow

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/user_spec.rb

# Run with coverage report
COVERAGE=true bundle exec rspec
```

### Database Operations

```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Reset database (drop, create, migrate, seed)
rails db:reset

# Seed data only
rails db:seed
```

### Background Jobs

```bash
# Generate reports for today
rails reports:generate_today

# Generate reports for a specific date
rails reports:generate_date[2024-01-15]

# Backfill reports for last N days
rails reports:generate_backfill[30]
```

### Sidekiq Web UI

Access the Sidekiq dashboard at: `http://localhost:3000/sidekiq`

## API Usage

### Authentication

Login to get a JWT token:

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@reportify.com", "password": "password123"}'
```

Response:

```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "user": {
      "id": 1,
      "email": "admin@reportify.com",
      "name": "Admin User",
      "role": "admin"
    }
  }
}
```

### Making Authenticated Requests

Include the token in the Authorization header:

```bash
curl http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Example Requests

**Get current user:**

```bash
curl http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**List items:**

```bash
curl http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Create item:**

```bash
curl -X POST http://localhost:3000/api/v1/items \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "category": "electronics",
    "price": 1299.99,
    "quantity": 5
  }'
```

**Get dashboard data:**

```bash
curl http://localhost:3000/api/v1/reports/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Project Structure

```
reportify-api/
├── app/
│   ├── controllers/
│   │   ├── concerns/          # Shared controller logic
│   │   └── api/v1/            # API v1 controllers
│   ├── models/                # ActiveRecord models
│   ├── services/              # Business logic services
│   │   ├── authentication/    # Auth services
│   │   ├── users/             # User services
│   │   ├── items/             # Item services
│   │   └── reports/           # Report services
│   ├── contracts/             # dry-validation contracts
│   └── workers/               # Sidekiq workers
├── config/
│   ├── initializers/          # Rails initializers
│   ├── environments/          # Environment configs
│   └── routes.rb              # API routes
├── db/
│   ├── migrate/               # Database migrations
│   └── seeds.rb               # Seed data
├── lib/
│   ├── jwt_encoder.rb         # JWT utility
│   └── tasks/                 # Rake tasks
├── spec/
│   ├── factories/             # FactoryBot factories
│   ├── models/                # Model tests
│   └── requests/              # Request tests
└── Gemfile                    # Ruby dependencies
```

## Key Features

### JWT Authentication

- Token-based authentication
- Secure password hashing with bcrypt
- Token expiration (24 hours)
- Role-based authorization (admin/user)

### Service Objects with dry-monads

- Functional approach to business logic
- Railway-oriented programming with do notation
- Consistent error handling
- Easy to test and compose

### Background Jobs

- Automated report generation
- Async processing with Sidekiq
- Retry mechanism for failed jobs
- Scheduled jobs support

### Validation with dry-validation

- Schema-based validation
- Type checking
- Custom validation rules
- Detailed error messages

## Testing

The application includes:

- Model tests with shoulda-matchers
- Request tests for API endpoints
- Factory definitions for test data
- SimpleCov for code coverage

Run tests with:

```bash
bundle exec rspec
```

## Production Deployment

### Environment Variables

Set the following in production:

- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `JWT_SECRET_KEY` - Secret key for JWT signing
- `RAILS_ENV=production`
- `RAILS_LOG_TO_STDOUT=enabled`

### Database

```bash
RAILS_ENV=production rails db:create db:migrate
```

### Assets and Precompilation

Not needed for API-only mode.

### Process Management

Use a process manager like Foreman, systemd, or Docker to manage:

1. Rails server (Puma)
2. Sidekiq workers
3. Redis server

## Troubleshooting

### Connection Issues

**Database connection error:**

- Check PostgreSQL is running: `pg_isready`
- Verify credentials in `.env`

**Redis connection error:**

- Check Redis is running: `redis-cli ping`
- Should return `PONG`

### Common Issues

**Migrations pending:**

```bash
rails db:migrate
```

**Sidekiq jobs not processing:**

- Make sure Redis is running
- Check Sidekiq is started: `bundle exec sidekiq`

**Authentication errors:**

- Check JWT_SECRET_KEY is set
- Verify token is being sent in Authorization header

## Production Deployment

The app is set up to deploy to a dedicated server using Kamal.

### Quick Deploy

```bash
# Check everything's ready
bin/check-deployment

# First time setup
bin/kamal setup -c config/deploy.production.yml

# Deploy
bin/deploy.production
```

### Deployment Details

API runs at `http://rs-development.net:3002` on these ports:

- App: 3002
- PostgreSQL: 5433
- Redis: 6380

The API doesn't handle HTTPS directly—your frontend server should do that and proxy requests here.

### Documentation

[QUICKSTART.md](QUICKSTART.md) - Get started quickly  
[DEPLOYMENT.md](DEPLOYMENT.md) - Full deployment guide

### What You Need

- Kamal installed (`gem install kamal`)
- SSH access to server (port 2121)
- `.env.production` file with your secrets
- Rails master key

## Contributing

1. Write tests for new features
2. Follow Ruby style guide
3. Use service objects for business logic
4. Add validation contracts for inputs
5. Document API changes

## License

MIT
