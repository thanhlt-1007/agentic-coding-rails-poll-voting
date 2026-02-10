# Rails Poll Voting

A modern polling and voting application built with Ruby 4 + Rails 8, featuring server-side rendering with Hotwire/Turbo and styled with Tailwind CSS.

## 📋 Prerequisites

Before you begin, ensure you have the following installed on your local machine:

- **Ruby**: 4.0.1 or higher
- **Rails**: 8.1.2 or higher
- **Bundler**: 4.0.3 or higher
- **PostgreSQL**: 15.0 or higher
- **Redis**: 7.0 or higher (for caching, background jobs, and Action Cable)
- **Node.js**: 18.0 or higher (for asset pipeline)
- **Git**: For version control

### Check Your Versions

```bash
ruby -v        # Should show Ruby 4.0+
rails -v       # Should show Rails 8.1+
bundle -v      # Should show Bundler 4.0.3+
psql --version # Should show PostgreSQL 15+
redis-server --version # Should show Redis 7+
node -v        # Should show Node 18+
```

## 🚀 Quick Start (Local Development)

### 1. Clone the Repository

```bash
git clone https://github.com/thanhlt-1007/agentic-coding-rails-poll-voting.git
cd agentic-coding-rails-poll-voting
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install JavaScript dependencies
bin/rails importmap:install
```

### 3. Configure Environment Variables

Copy the example environment file and update with your local values:

```bash
cp .env.example .env
```

Edit `.env` and set your database credentials:

```env
POLL_VOTING_DATABASE_HOST=localhost
POLL_VOTING_DATABASE_PORT=5432
POLL_VOTING_DATABASE_USERNAME=your_postgres_username
POLL_VOTING_DATABASE_PASSWORD=your_postgres_password
```

> **Note**: The `.env` file is ignored by git. Never commit sensitive credentials.

### 4. Setup Database

```bash
# Create databases
bin/rails db:create

# Run migrations
bin/rails db:migrate

# (Optional) Seed with sample data
bin/rails db:seed
```

### 5. Start Redis

Redis is required for Solid Cache, Solid Queue, and Solid Cable.

```bash
# On macOS with Homebrew
brew services start redis

# On Linux
sudo systemctl start redis

# Or run in foreground for development
redis-server
```

### 6. Start the Development Server

```bash
# Start Rails server
bin/dev
```

The application will be available at **http://localhost:3000**

## 🚀 Production Environment (Render.com Only)

### Automatic Environment Variables

When deploying to Render.com, the following environment variables are **automatically provided** by the platform. You do NOT need to set them manually:

#### `DATABASE_URL`
- **Auto-provided**: Yes (Render.com managed PostgreSQL)
- **Format**: `postgres://username:password@host:port/database`
- **Usage**: Production database connection (primary, cache, queue, cable)
- **⚠️ IMPORTANT**: Do NOT set `DATABASE_URL` in your local `.env` file!
  - Setting it locally will **override** all individual database variables (`POLL_VOTING_DATABASE_HOST`, `POLL_VOTING_DATABASE_PORT`, etc.)
  - This will break your local development setup
  - `DATABASE_URL` is only needed in production where Render.com provides it automatically

#### `REDIS_URL`
- **Auto-provided**: Yes (Render.com managed Redis)
- **Format**: `redis://hostname:port`
- **Usage**: Caching, background jobs, Action Cable

#### Manual Configuration Required

You must manually configure these variables in the Render.com dashboard:

- `RAILS_MASTER_KEY` - Copy from `config/master.key` (never commit this file!)
- `RAILS_ENV=production`
- `RAILS_LOG_LEVEL=info` (recommended)
- `RAILS_FORCE_SSL=true`

### Local vs Production Database Configuration

**Local Development** (uses individual variables from `.env`):
```env
POLL_VOTING_DATABASE_HOST=localhost
POLL_VOTING_DATABASE_PORT=5432
POLL_VOTING_DATABASE_USERNAME=postgres
POLL_VOTING_DATABASE_PASSWORD=your_password
```

**Production** (uses single `DATABASE_URL` from Render.com):
```env
DATABASE_URL=postgres://user:pass@host:5432/dbname  # Auto-provided, do NOT set manually
```

Rails automatically parses `DATABASE_URL` in production to create the primary database connection and derives cache/queue/cable database names from it.

## 🧪 Running Tests

### Run All Tests

```bash
bin/rails test
```

### Run Specific Test Files

```bash
bin/rails test test/models/poll_test.rb
bin/rails test test/controllers/polls_controller_test.rb
```

### Run System Tests

```bash
bin/rails test:system
```

### Code Quality Checks

```bash
# Run Rubocop (code style)
bundle exec rubocop

# Run Brakeman (security scan)
bundle exec brakeman

# Run Bundler Audit (dependency vulnerabilities)
bundle exec bundle-audit check --update
```

## 📁 Project Structure

```
.
├── app/
│   ├── controllers/      # Request handlers (MVC Controllers)
│   ├── models/           # Data models (Active Record)
│   ├── views/            # HTML templates (ERB + Turbo)
│   ├── components/       # ViewComponents (reusable UI)
│   ├── jobs/             # Background jobs (Solid Queue)
│   ├── mailers/          # Email templates
│   └── assets/           # CSS, JavaScript, images
├── config/
│   ├── database.yml      # Database configuration
│   ├── routes.rb         # URL routing
│   └── environments/     # Environment-specific configs
├── db/
│   ├── migrate/          # Database migrations
│   └── schema.rb         # Current database schema
├── test/                 # Test files
├── specs/                # Feature specifications
├── .env.example          # Environment variables template
└── README.md             # This file
```

## � Authentication

This application uses [Devise](https://github.com/heartcombo/devise) for user authentication.

### User Registration

Users can sign up at `/sign_up` with:
- Email address (unique, case-insensitive)
- Password (minimum 6 characters)
- Password confirmation

### Features

- **Secure password storage**: Passwords are encrypted using bcrypt
- **Email validation**: Standard email format required
- **Password requirements**: Minimum 6 characters
- **Password confirmation**: Prevents typing errors
- **Auto sign-in**: Users are automatically signed in after successful registration
- **Error messages**: Clear, actionable feedback for validation errors

### Devise Configuration

Configured modules in `app/models/user.rb`:
- `:database_authenticatable` - Email/password login
- `:registerable` - User registration
- `:recoverable` - Password reset
- `:rememberable` - Remember me cookie
- `:validatable` - Email and password validations

### Custom Routes

Authentication routes are available at:
- Sign up: `/sign_up`
- Login: `/login`
- Logout: `/logout`

### Testing Authentication

```bash
# Run user model tests
bin/rails test test/models/user_test.rb

# Run sign-up system tests
bin/rails test test/system/user_signup_test.rb
```

## �🔧 Common Development Tasks

### Create a New Model

```bash
bin/rails generate model Poll title:string description:text expires_at:datetime
bin/rails db:migrate
```

### Create a New Controller

```bash
bin/rails generate controller Polls index show new create
```

### Generate a Migration

```bash
bin/rails generate migration AddVotesCountToPolls votes_count:integer
bin/rails db:migrate
```

### Reset Database

```bash
bin/rails db:drop db:create db:migrate db:seed
```

### Rails Console

```bash
# Development console
bin/rails console

# Production console (use with caution!)
RAILS_ENV=production bin/rails console
```

### Background Jobs

```bash
# View Solid Queue dashboard
# Visit http://localhost:3000/solid_queue after starting server

# Process jobs manually (if needed)
bin/rails solid_queue:start
```

## 🛠️ Technology Stack

- **Backend**: Ruby 4.0, Rails 8.1
- **Database**: PostgreSQL 15+
- **Caching**: Redis 7+ (Solid Cache)
- **Background Jobs**: Solid Queue
- **Real-time**: Solid Cable (WebSockets)
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Styling**: Tailwind CSS 4
- **Testing**: Minitest + Capybara
- **Deployment**: Render.com

## 🌍 Environment Configuration

### Development

Default configuration loads from `.env` file. Key variables:

- `POLL_VOTING_DATABASE_HOST` - PostgreSQL host (default: localhost)
- `POLL_VOTING_DATABASE_PORT` - PostgreSQL port (default: 5432)
- `POLL_VOTING_DATABASE_USERNAME` - PostgreSQL username
- `POLL_VOTING_DATABASE_PASSWORD` - PostgreSQL password
- `REDIS_URL` - Redis connection URL (default: redis://localhost:6379/0)

### Test

Test environment can override settings via `.env.test` file.

### Production

Production environment variables are automatically provided by Render.com. See the **Production Environment (Render.com Only)** section above for complete details on `DATABASE_URL`, `REDIS_URL`, and manual configuration requirements.

**Key Point**: Never set `DATABASE_URL` in local `.env` - it will override your local database configuration!

## 🐛 Troubleshooting

### Database Connection Error

```bash
# Ensure PostgreSQL is running
sudo systemctl status postgresql   # Linux
brew services list                 # macOS

# Check database exists
psql -l | grep poll_voting
```

### Redis Connection Error

```bash
# Ensure Redis is running
redis-cli ping  # Should return "PONG"

# Check Redis URL in .env matches your setup
echo $REDIS_URL
```

### Asset Compilation Issues

```bash
# Clear Tailwind CSS cache
bin/rails tailwindcss:build

# Clear asset cache
bin/rails assets:clobber
```

### Permission Errors

```bash
# Fix file permissions
chmod +x bin/dev bin/rails bin/setup

# Reinstall dependencies
rm -rf node_modules
bundle install
```

## 📚 Additional Resources

- [Rails Guides](https://guides.rubyonrails.org/) - Official Rails documentation
- [Hotwire Docs](https://hotwired.dev/) - Turbo and Stimulus guides
- [Tailwind CSS](https://tailwindcss.com/docs) - Styling framework
- [PostgreSQL Docs](https://www.postgresql.org/docs/) - Database documentation
- [Project Constitution](.specify/memory/constitution.md) - Development standards and principles

## 🤝 Contributing

1. Create a feature branch: `git checkout -b 001-feature-name`
2. Follow the [Constitution](.specify/memory/constitution.md) principles
3. Write tests first (TDD approach)
4. Run code quality checks before committing
5. Submit a pull request with clear description

## 📄 License

[Add your license information here]

## 👥 Team

[Add team information or links here]

---

**Need Help?** Check the [specs/](specs/) directory for detailed feature documentation or consult the project constitution in [.specify/memory/constitution.md](.specify/memory/constitution.md).
