-- Credit Card Buddy Database Schema

-- Users table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Credit cards table
CREATE TABLE credit_cards (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  card_name VARCHAR(100) NOT NULL,
  issuer VARCHAR(100) NOT NULL,
  last_4 VARCHAR(4) NOT NULL,
  reward_program VARCHAR(100),
  current_balance DECIMAL(12, 2) DEFAULT 0,
  available_credit DECIMAL(12, 2) DEFAULT 0,
  due_date DATE,
  monthly_spend DECIMAL(12, 2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, last_4)
);

-- Transactions table
CREATE TABLE transactions (
  id SERIAL PRIMARY KEY,
  card_id INTEGER NOT NULL REFERENCES credit_cards(id) ON DELETE CASCADE,
  merchant_name VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  amount DECIMAL(12, 2) NOT NULL,
  transaction_date DATE NOT NULL,
  description TEXT,
  status VARCHAR(50) DEFAULT 'completed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Spend categories table
CREATE TABLE spend_categories (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category_name VARCHAR(100) NOT NULL,
  amount DECIMAL(12, 2) DEFAULT 0,
  color VARCHAR(7),
  percent INTEGER DEFAULT 0,
  month DATE NOT NULL,
  UNIQUE(user_id, category_name, month)
);

-- Dashboard summary cache
CREATE TABLE dashboard_summary (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  total_cards INTEGER DEFAULT 0,
  monthly_spend DECIMAL(12, 2) DEFAULT 0,
  total_rewards DECIMAL(12, 2) DEFAULT 0,
  next_payment_due DATE,
  next_redemption_hint TEXT,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for common queries
CREATE INDEX idx_credit_cards_user_id ON credit_cards(user_id);
CREATE INDEX idx_transactions_card_id ON transactions(card_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_spend_categories_user_id ON spend_categories(user_id);
