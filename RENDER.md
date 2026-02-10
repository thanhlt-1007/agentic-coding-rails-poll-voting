# Render.com Deployment Guide

Complete guide for deploying Rails Poll Voting application to Render.com.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Service Configuration](#service-configuration)
- [Environment Variables](#environment-variables)
- [Database Setup](#database-setup)
- [Deployment Process](#deployment-process)
- [Post-Deployment](#post-deployment)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before deploying, ensure you have:

- [x] GitHub repository with Rails application code
- [x] Render.com account (free tier available at https://render.com)
- [x] `config/master.key` file locally (needed for RAILS_MASTER_KEY)
- [x] All migrations committed to main/develop branch
- [x] Database.yml configured to use `DATABASE_URL` in production (✅ already configured)

---

## Initial Setup

### 1. Create Render.com Account

1. Visit https://render.com
2. Sign up with GitHub account (recommended for easier deployment)
3. Authorize Render to access your repositories

### 2. Connect GitHub Repository

1. From Render Dashboard, go to **"New +"** → **"Web Service"**
2. Select **"Build and deploy from a Git repository"**
3. Click **"Connect GitHub"** or use existing connection
4. Find and select repository: `thanhlt-1007/agentic-coding-rails-poll-voting`
5. Click **"Connect"**

---

## Service Configuration

### Web Service Settings

Configure the following settings for your web service:

| Setting | Value | Notes |
|---------|-------|-------|
| **Name** | `agentic-coding-rails-poll-voting` | URL will be `name.onrender.com` |
| **Region** | `Oregon (US West)` or closest to users | Choose based on target audience |
| **Branch** | `main` or `develop` | Auto-deploy on push |
| **Runtime** | `Ruby` | Detected automatically |
| **Build Command** | `bundle install && bundle exec rails assets:precompile && bundle exec rails db:prepare` | See details below |
| **Start Command** | `bundle exec rails server -b 0.0.0.0` | Binds to all interfaces |
| **Instance Type** | `Free` (Starter: $7/month for 24/7) | Free spins down after inactivity |

### Build Command Breakdown

```bash
bundle install &&                          # Install Ruby gems
bundle exec rails assets:precompile &&     # Compile CSS/JS assets
bundle exec rails db:prepare               # Create DB + run migrations
```

**⚠️ Important Notes**:
- `db:prepare` is idempotent (safe to run multiple times)
- Combines `db:create`, `db:migrate`, and `db:seed` intelligently
- Runs every deployment to ensure database is up-to-date

### Start Command

```bash
bundle exec rails server -b 0.0.0.0
```

**Why `-b 0.0.0.0`?**  
Render uses a reverse proxy. Rails must bind to all network interfaces (0.0.0.0) to receive traffic, not just localhost.

---

## Environment Variables

### Auto-Provided by Render (Do NOT Set Manually)

These are automatically injected when you add managed services:

- `DATABASE_URL` - PostgreSQL connection string (format: `postgres://user:pass@host:port/dbname`)
- `REDIS_URL` - Redis connection string (format: `redis://hostname:port`)
- `RENDER` - Set to `"true"` (useful for conditional logic)
- `RENDER_INSTANCE_ID` - Unique instance identifier
- `RENDER_SERVICE_NAME` - Service name
- `RENDER_GIT_COMMIT` - Deployed commit SHA
- `RENDER_GIT_BRANCH` - Deployed branch name

### Required Manual Configuration

Add these in **Render Dashboard → Service → Environment**:

#### Critical (Required)

```bash
# Rails master key for encrypted credentials
RAILS_MASTER_KEY=<copy_from_config/master.key>

# Rails environment
RAILS_ENV=production

# Force SSL connections
RAILS_FORCE_SSL=true

# Log level (info recommended for production)
RAILS_LOG_LEVEL=info
```

#### Optional (Performance & Features)

```bash
# Max threads for Puma web server (default: 5)
RAILS_MAX_THREADS=5

# Database connection pool size (should match RAILS_MAX_THREADS)
DB_POOL=5

# Time zone
TZ=UTC
```

### How to Get RAILS_MASTER_KEY

**Option 1: From existing file**
```bash
cat config/master.key
```

**Option 2: Generate new credentials**
```bash
EDITOR=nano rails credentials:edit
# This creates config/master.key and config/credentials.yml.enc
cat config/master.key
```

**⚠️ Security Warning**: NEVER commit `config/master.key` to Git! It's already in `.gitignore`.

---

## Database Setup

### Create PostgreSQL Database

1. From Render Dashboard, go to **"New +"** → **"PostgreSQL"**
2. Configure database:
   - **Name**: `poll-voting-db`
   - **Database**: `poll_voting_production` (or auto-generated)
   - **User**: Auto-generated
   - **Region**: Same as web service (for low latency)
   - **PostgreSQL Version**: `15` or higher
   - **Instance Type**: `Free` (1GB storage, expires after 90 days) or `Starter` ($7/month, 10GB storage)

3. Click **"Create Database"**

### Link Database to Web Service

1. Go to **Web Service** → **Environment** tab
2. Render automatically provides `DATABASE_URL` when services are in the same team
3. If not auto-linked:
   - Copy **Internal Database URL** from PostgreSQL service
   - Add as `DATABASE_URL` environment variable in web service

### Database Configuration Verification

The application is already configured to use `DATABASE_URL`:

**config/database.yml** (production section):
```yaml
production:
  primary:
    url: <%= ENV['DATABASE_URL'] %>
  cache:
    url: <%= ENV['DATABASE_URL']&.sub(/\/([^\/]+)$/, '/\1_cache') %>
  queue:
    url: <%= ENV['DATABASE_URL']&.sub(/\/([^\/]+)$/, '/\1_queue') %>
  cable:
    url: <%= ENV['DATABASE_URL']&.sub(/\/([^\/]+)$/, '/\1_cable') %>
```

This creates 4 databases from single `DATABASE_URL`:
- `poll_voting_production` (primary)
- `poll_voting_production_cache` (Solid Cache)
- `poll_voting_production_queue` (Solid Queue)
- `poll_voting_production_cable` (Solid Cable)

---

## Deployment Process

### First Deployment

1. **Ensure all required environment variables are set** (see Environment Variables section)
2. **Push code to GitHub** (main/develop branch)
3. **Render will automatically**:
   - Detect Ruby runtime
   - Run build command
   - Create databases (via `db:prepare`)
   - Run migrations
   - Start web server
4. **Monitor deployment** in Render Dashboard → Logs

### Deployment Timeline

Typical deployment takes **3-5 minutes**:

- ⏱️ **0:00-0:30** - Git clone
- ⏱️ **0:30-2:00** - Bundle install (gems)
- ⏱️ **2:00-3:00** - Asset precompilation (Tailwind CSS, Importmap)
- ⏱️ **3:00-3:30** - Database preparation
- ⏱️ **3:30-5:00** - Server startup

### Subsequent Deployments

Every push to connected branch triggers automatic deployment:

1. Commit changes locally
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

2. Push to GitHub
   ```bash
   git push origin main  # or develop
   ```

3. Render automatically:
   - Detects push via webhook
   - Starts new deployment
   - Runs build command
   - Zero-downtime switchover (paid plans) or brief downtime (free tier)

### Manual Deployment

If automatic deployment fails or you need to redeploy:

1. Go to **Web Service** → **Manual Deploy**
2. Select **"Clear build cache & deploy"** (if dependencies changed)
3. Click **"Deploy"**

---

## Post-Deployment

### 1. Verify Deployment

#### Check Service Status
- Dashboard shows **"Live"** with green indicator
- Logs show: `Listening on http://0.0.0.0:<port>`

#### Test Application

```bash
# Replace with your actual URL
curl https://agentic-coding-rails-poll-voting.onrender.com

# Or visit in browser
open https://agentic-coding-rails-poll-voting.onrender.com
```

#### Verify Health Check

```bash
curl https://agentic-coding-rails-poll-voting.onrender.com/up
# Expected: 200 OK
```

### 2. Check Database Connectivity

```bash
# SSH into Render shell (from dashboard)
bundle exec rails console

# Test database connection
ActiveRecord::Base.connection.execute("SELECT version()").first
# Expected: PostgreSQL version info

# Check database names
ActiveRecord::Base.connection.execute("SELECT current_database()").first
# Expected: poll_voting_production
```

### 3. Verify Background Jobs (Solid Queue)

```bash
# In Rails console
SolidQueue::Job.count
# Expected: 0 or higher (no errors)
```

### 4. Test Redis Connection (Solid Cache)

```bash
# In Rails console
Rails.cache.write('test', 'success')
Rails.cache.read('test')
# Expected: "success"
```

---

## Monitoring & Maintenance

### Logs

Access real-time logs:

1. **Render Dashboard** → **Service** → **Logs** tab
2. View recent logs or stream live logs

Common log locations in Rails:
```ruby
# Log to STDOUT (captured by Render)
Rails.logger.info "Custom message"

# Production logs already configured to STDOUT
# See config/environments/production.rb
```

### Metrics

Free tier includes basic metrics:

- **CPU Usage**
- **Memory Usage**
- **HTTP Request Count**
- **Response Times** (p50, p95, p99)

Paid plans include:
- Custom alerts
- Extended log retention
- Advanced metrics

### Database Backups

**Free PostgreSQL**:
- No automatic backups
- Database expires after 90 days

**Paid PostgreSQL** ($7/month+):
- Daily automated backups
- 7-day retention (Starter)
- Point-in-time recovery (Pro)

**Manual Backup** (free tier):
```bash
# From local machine
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql
```

### SSL/TLS Certificates

- **Automatic**: Render provides free SSL certificates via Let's Encrypt
- **Custom Domain**: Configure in Dashboard → Custom Domains
- **Auto-renewal**: Certificates renew automatically

---

## Troubleshooting

### Deployment Failures

#### Build Failed: Bundle Install Error

**Symptom**: `An error occurred while installing <gem>`

**Solution**:
```bash
# Check Gemfile.lock is committed
git add Gemfile.lock
git commit -m "chore: add Gemfile.lock"
git push

# Or regenerate Gemfile.lock
bundle lock --update
git commit -am "chore: update Gemfile.lock"
```

#### Build Failed: Asset Precompilation Error

**Symptom**: `Sprockets::Rails::Helper::AssetNotFound`

**Solution**:
- Ensure all asset files are committed
- Check `app/assets/` directory exists
- Verify Tailwind CSS installed: `bundle list | grep tailwindcss`

#### Database Migration Failed

**Symptom**: `PG::ConnectionBad: could not connect to server`

**Solution**:
1. Verify `DATABASE_URL` is set in environment variables
2. Check PostgreSQL service is running (Dashboard → Database → Status)
3. Verify database region matches web service region

### Runtime Errors

#### 500 Internal Server Error

**Symptom**: Application returns 500 status

**Solution**:
```bash
# Check logs for error details
# Dashboard → Logs

# Common causes:
# 1. Missing RAILS_MASTER_KEY
# 2. Database connection failure
# 3. Missing environment variable

# Verify master key is set correctly
echo $RAILS_MASTER_KEY  # In Render shell
```

#### "Not Found" (404) Error

**Symptom**: All routes return 404

**Solution**:
- Verify root route is defined in `config/routes.rb`
- Check routes: `bundle exec rails routes` (in Render shell)
- Ensure controller and views exist

#### Database Connection Pool Exhausted

**Symptom**: `ActiveRecord::ConnectionTimeoutError`

**Solution**:
```bash
# Increase pool size (match RAILS_MAX_THREADS)
# Add environment variable:
DB_POOL=10
RAILS_MAX_THREADS=10

# Or update database.yml:
pool: <%= ENV.fetch("DB_POOL") { 10 } %>
```

### Performance Issues

#### Slow Response Times

**Check**:
1. **Database queries**: Use `rack-mini-profiler` gem
2. **N+1 queries**: Use `bullet` gem
3. **Missing indexes**: Check `db/schema.rb`
4. **Instance type**: Upgrade from Free to Starter/Standard

**Solution**:
```bash
# Add eager loading in controllers
@polls = Poll.includes(:votes).all

# Add database indexes
rails generate migration AddIndexToVotesOnPollId
# In migration:
add_index :votes, :poll_id
```

#### Memory Limit Exceeded (Free Tier: 512MB)

**Symptom**: Service restarts frequently

**Solution**:
1. **Reduce memory usage**:
   ```bash
   # Decrease Puma workers (if configured)
   WEB_CONCURRENCY=1  # Default for free tier
   
   # Decrease threads
   RAILS_MAX_THREADS=3
   ```

2. **Upgrade instance type**: Starter ($7/month) provides 2GB RAM

### Free Tier Spin-Down

**Issue**: Free tier spins down after 15 minutes of inactivity

**Symptoms**:
- First request after inactivity takes 30-60 seconds (cold start)
- Subsequent requests are fast

**Solutions**:
1. **Upgrade to Starter** ($7/month) - Always on, no spin-down
2. **Keep alive service** (external ping):
   ```bash
   # Use cron-job.org or UptimeRobot
   # Ping every 10 minutes:
   curl https://your-app.onrender.com/up
   ```

---

## Advanced Configuration

### Custom Domain

1. **Add domain** in Render Dashboard → Custom Domains
2. **Configure DNS** (at your domain registrar):
   ```
   Type: CNAME
   Name: www (or @)
   Value: <your-service>.onrender.com
   ```
3. **SSL certificate** auto-provisioned by Render

### Environment-Specific Branches

Deploy different branches to different environments:

| Environment | Branch | URL |
|-------------|--------|-----|
| Production | `main` | `app.example.com` |
| Staging | `develop` | `staging-app.onrender.com` |
| Preview | `feature/*` | Auto-generated preview URLs |

### Background Workers (Solid Queue)

Solid Queue runs in the same web process (no separate worker needed):

- Configured in `config/environments/production.rb`:
  ```ruby
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }
  ```
- Uses `poll_voting_production_queue` database
- Processes jobs asynchronously

### Redis Configuration (Future)

If switching from Solid Cache to Redis:

1. **Add Redis service** in Render Dashboard
2. **Link to web service** (REDIS_URL auto-provided)
3. **Update `config/environments/production.rb`**:
   ```ruby
   config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'] }
   ```

---

## Deployment Checklist

Use this checklist for each deployment:

### Pre-Deployment

- [ ] All tests passing locally (`bin/rails test`)
- [ ] Database migrations committed
- [ ] Assets precompile locally (`RAILS_ENV=production bin/rails assets:precompile`)
- [ ] No credentials in code (use Rails credentials or ENV vars)
- [ ] `config/master.key` backed up securely (not in Git!)

### Deployment

- [ ] Push to correct branch (main/develop)
- [ ] Monitor build logs in Render Dashboard
- [ ] Verify build completes successfully
- [ ] Check deployment status shows "Live"

### Post-Deployment

- [ ] Test application URL (HTTP 200)
- [ ] Test health check endpoint (`/up`)
- [ ] Verify database connectivity (Rails console)
- [ ] Check logs for errors
- [ ] Test critical user flows (create poll, vote, view results)
- [ ] Verify background jobs processing (if applicable)

---

## Security Best Practices

1. **Never commit secrets**:
   - `config/master.key` → `.gitignore` ✅
   - `.env` files → `.gitignore` ✅
   - Use Rails credentials for sensitive data

2. **Enable Force SSL**:
   ```bash
   RAILS_FORCE_SSL=true  # Set in Render environment
   ```

3. **Rotate RAILS_MASTER_KEY periodically**:
   ```bash
   # Generate new credentials
   rails credentials:edit
   
   # Update Render environment variable
   # Deploy to activate
   ```

4. **Database security**:
   - Use internal DATABASE_URL (not public)
   - Render databases use SSL by default
   - No direct internet access (only through Render network)

5. **Keep dependencies updated**:
   ```bash
   bundle update --conservative
   bundle exec bundle-audit check --update
   git commit -am "chore: update dependencies"
   ```

---

## Cost Estimation

### Free Tier (Suitable for POC/Testing)

- **Web Service**: Free (spins down after 15 min inactivity)
- **PostgreSQL**: Free (1GB, expires 90 days)
- **Redis**: Not available on free tier (use Solid Cache ✅)
- **Total**: $0/month

### Starter Tier (Production-Ready)

- **Web Service**: $7/month (always on, 512MB RAM)
- **PostgreSQL Starter**: $7/month (10GB, daily backups)
- **Redis Starter** (optional): $10/month (25MB)
- **Total**: $14-24/month

### Professional Tier (High Traffic)

- **Web Service Standard**: $25/month (2GB RAM)
- **PostgreSQL Standard**: $20/month (50GB, point-in-time recovery)
- **Redis Standard**: $30/month (1GB)
- **Total**: $45-75/month

---

## Additional Resources

- **Render Documentation**: https://render.com/docs
- **Rails Deployment Guide**: https://guides.rubyonrails.org/deployment.html
- **Render Community**: https://community.render.com
- **Rails 8 Solid Queue**: https://github.com/rails/solid_queue
- **Rails 8 Solid Cache**: https://github.com/rails/solid_cache

---

## Support

### Render Support

- **Free Tier**: Community forum only
- **Paid Tiers**: Email support
- **Community Forum**: https://community.render.com

### Application Support

For issues specific to this application:

1. Check logs in Render Dashboard
2. Review troubleshooting section above
3. Check [README.md](README.md) for local development setup
4. Review [constitution.md](.specify/memory/constitution.md) for project standards

---

**Last Updated**: February 10, 2026  
**Version**: 1.0.0  
**Status**: Production Ready ✅
