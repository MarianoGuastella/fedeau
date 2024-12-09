# Products API

This is a simple API built with Ruby on Rails that provides endpoints for authentication, product creation, and product retrieval. It uses JWT for authentication, PostgreSQL for data storage, and Sidekiq with Redis for asynchronous task handling. The application also syncs products with an external API during the first startup. It can be run with docker or natively.

## Installation Requirements

### Option 1: Using Docker (Recommended)

You only need:

- Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- Git

### Option 2: Traditional Installation

You need to install:

- Git
- Ruby 3.3.5 (using rbenv)
- Rails 7.2.2
- PostgreSQL 14
- Redis 7.4

## Installation

### With Docker (Recommended)

1. Clone the repository

```bash
git clone https://github.com/MarianoGuastella/fedeau.git
cd fedeau
```

2. Set up environment

```bash
cp .env.example .env
# Edit .env with your settings
```

3. Build and start containers

```bash
chmod +x bin/*
sudo usermod -aG docker $USER
newgrp docker
docker compose up --build
```

4. Create and set up database (in another terminal)

```bash
sudo usermod -aG docker $USER
newgrp docker
docker compose exec web bin/rails db:create
docker compose exec web bin/rails db:migrate
```

5. Create test user

```bash
docker compose exec web bin/rails console
# In the Rails console:
User.create!(username: "test_user", password: "password123")
# Type 'exit' to leave the console
```

### Without Docker

1. Install dependencies (Ubuntu/Debian):

   ### Update the List of Official Packages

   ```bash
   sudo apt-get update
   ```

   ### Install a Ruby Version Manager

   ```bash
   sudo apt install rbenv
   ```

   ### Configure rbenv (If Not Added Automatically)

   Add the following to ~/.bashrc:

   ```bash
   export PATH="$HOME/.rbenv/bin:$PATH"
   eval "$(rbenv init -)"
   ```

   ### Get the Latest Version of ruby-build

   ```bash
   git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
   ```

   ### Install ruby-build Dependencies

   ```bash
   sudo apt-get install autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
   ```

   ### Install the Latest Version of Ruby

   ```bash
   rbenv install 3.3.5
   ```

   ### Set the Global Ruby Version

   ```bash
   rbenv global 3.3.5
   ```

   ### Verify the Installed Version

   ```bash
   ruby -v
   ```

   ### Install PostgreSQL and Redis

   ```bash
   sudo apt install postgresql postgresql-contrib libpq-dev bundler git redis-server
   ```

2. Clone and configure the project

   ```bash
   git clone https://github.com/MarianoGuastella/fedeau.git
   cd fedeau
   bundle install
   cp .env.example .env # Edit .env with your settings
   rails db:create db:migrate
   ```

3. Start services (in separate terminals)

   ```bash
   # Terminal 1: Redis
   redis-server

   # Terminal 2: Sidekiq
   bundle exec sidekiq

   # Terminal 3: Rails server
   rails server
   ```

## Useful Commands

### With Docker

```bash
# Run tests
docker compose exec web bin/rails test

# Access Rails console
docker compose exec web bin/rails console

# View logs
docker compose logs -f

# Stop containers
docker compose down
```

### Without Docker

```bash
# Run tests
rails test

# Access console
rails console

# View Sidekiq logs
tail -f log/sidekiq.log

# Stop services
# Ctrl+C in each terminal to stop Rails, Sidekiq and Redis
```

## API Endpoints

- `POST /api/auth/login` - Login (returns access token)

```bash
  curl -X POST http://0.0.0.0:3000/api/authentication/login -H "Content-Type: application/json" -d '{"username": "test_user", "password": "password123"}'
```

- `GET /api/products` - List products (requires access token)

```bash
 curl -X GET http://0.0.0.0:3000/api/products -H "Authorization: Bearer your_token"
```

- `POST /api/products` - Create product (requires access token)

```bash
 curl -X POST http://0.0.0.0:3000/api/products   -H "Authorization: Bearer your_token"   -H "Content-Type: application/json"   -d '{"name": "Orange"}'
```

## Configuration

- Ruby version: 3.3.5
- Database system: PostgreSQL 14
- Cache and queue system: Redis 7.4 + Sidekiq
