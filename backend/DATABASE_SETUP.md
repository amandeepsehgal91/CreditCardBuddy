# Credit Card Buddy Backend with PostgreSQL

This backend uses PostgreSQL + Sequelize ORM to manage credit card, user, and transaction data.

## Quick Start

### Prerequisites
- Node.js 16+
- PostgreSQL 12+
- npm or yarn

### 1. Setup PostgreSQL

If you don't have PostgreSQL installed:

```bash
# macOS (with Homebrew)
brew install postgresql@15
brew services start postgresql@15

# Or use Docker
docker run --name ccbuddy-db -e POSTGRES_PASSWORD=password -e POSTGRES_DB=credit_card_buddy -p 5432:5432 -d postgres:15
```

### 2. Create database and user (if manual setup)

```bash
psql -U postgres
CREATE DATABASE credit_card_buddy;
CREATE USER ccbuddy_user WITH PASSWORD 'secure_password';
ALTER ROLE ccbuddy_user SET client_encoding TO 'utf8';
ALTER ROLE ccbuddy_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE ccbuddy_user SET default_transaction_deferrable TO on;
ALTER ROLE ccbuddy_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE credit_card_buddy TO ccbuddy_user;
\q
```

### 3. Configure environment

```bash
# Copy the example env file
cp .env.example .env

# Edit .env with your database credentials
nano .env
```

### 4. Install dependencies

```bash
npm install
```

### 5. Start the backend

Development mode (with auto-reload):
```bash
npm run dev
```

Production:
```bash
npm run build
npm start
```

## API Endpoints

### Mock Dashboard (legacy)
- `GET /dashboard` - Returns mock dashboard data

### Real Database Endpoints

#### Dashboard
- `GET /api/v1/dashboard/:userId` - Get user's dashboard with all cards

#### Cards
- `GET /api/v1/cards/:cardId/transactions` - Get transactions for a card
- `POST /api/v1/users/:userId/cards` - Add a new credit card

## Database Schema

The schema includes:
- **users** - User accounts
- **credit_cards** - Credit cards per user
- **transactions** - Card transactions
- **spend_categories** - Monthly spend breakdown
- **dashboard_summary** - Cached dashboard data

All tables have proper indexes and relationships configured.

## Development

### Running migrations
Migrations are handled automatically by Sequelize in development mode. To reset:

```bash
npm run db:reset
```

### Seeding sample data

```bash
npm run db:seed
```

## Troubleshooting

**Cannot connect to database:**
- Check PostgreSQL is running: `psql -U postgres -c "SELECT version();"`
- Verify credentials in `.env` file
- Check database exists: `psql -U postgres -l`

**Port 5432 already in use:**
- Kill the process: `lsof -ti:5432 | xargs kill -9`
- Or use a different port in `.env`

## Next Steps

1. Implement JWT authentication
2. Add transaction sync from bank APIs (Finvu, OneMoney)
3. Implement spend analytics queries
4. Add data validation and error handling
5. Create admin dashboard for data monitoring
