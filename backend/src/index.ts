import express from 'express';
import cors from 'cors';
import dashboardRouter from './dashboard';
import { syncDatabase, User, CreditCard, Transaction } from './database';

const app = express();
const port = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());

// Initialize database
syncDatabase().then(() => {
  console.log('Database ready.');
});

app.get('/', (req, res) => {
  res.send({ status: 'Credit Card Buddy API', version: '0.2.0', features: ['database', 'auth'] });
});

app.get('/health', (req, res) => {
  res.send({ status: 'ok' });
});

// Deprecated: Mock dashboard endpoint (kept for backward compatibility)
app.use('/dashboard', dashboardRouter);

// NEW: Real database-backed dashboard endpoint
app.get('/api/v1/dashboard/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Fetch user's cards
    const cards = await CreditCard.findAll({
      where: { user_id: userId },
    });

    if (!cards || cards.length === 0) {
      return res.status(200).json({
        summary: {
          totalCards: 0,
          monthlySpend: 0,
          totalRewards: 0,
          nextPaymentDue: null,
          nextRedemptionHint: 'Connect your first card to get started',
        },
        cards: [],
        spendCategories: [],
      });
    }

    // Calculate totals
    const totalCards = cards.length;
    const monthlySpend = cards.reduce((sum, card) => sum + (Number(card.monthly_spend) || 0), 0);
    const nextPaymentDue = cards
      .map((c) => c.due_date)
      .filter((d) => d)
      .sort()[0];

    res.send({
      summary: {
        totalCards,
        monthlySpend,
        totalRewards: 12450, // TODO: Calculate from transactions
        nextPaymentDue,
        nextRedemptionHint: 'Use HDFC Miles for travel',
      },
      cards: cards.map((card) => ({
        id: card.id,
        issuer: card.issuer,
        cardName: card.card_name,
        last4: card.last_4,
        rewardProgram: card.reward_program,
        currentBalance: card.current_balance,
        availableCredit: card.available_credit,
        dueDate: card.due_date,
        monthlySpend: card.monthly_spend,
      })),
      spendCategories: [
        { name: 'Dining', amount: 6200, color: '#FF9F1C', percent: 37 },
        { name: 'Travel', amount: 4200, color: '#2EC4B6', percent: 25 },
        { name: 'Groceries', amount: 3600, color: '#8D99AE', percent: 21 },
        { name: 'Shopping', amount: 2400, color: '#EF476F', percent: 17 },
      ],
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch dashboard', details: error.message });
  }
});

// NEW: Get transactions for a card with optional filtering
app.get('/api/v1/cards/:cardId/transactions', async (req, res) => {
  try {
    const { cardId } = req.params;
    const { startDate, endDate, category, search, limit = 50, offset = 0 } = req.query;

    // Build where clause
    const where: any = { card_id: cardId };

    // Date range filtering
    if (startDate || endDate) {
      where.transaction_date = {};
      if (startDate) {
        where.transaction_date.$gte = new Date(String(startDate));
      }
      if (endDate) {
        where.transaction_date.$lte = new Date(String(endDate));
      }
    }

    // Category filtering
    if (category) {
      where.category = String(category);
    }

    // Search by merchant or description
    if (search) {
      const { Op } = require('sequelize');
      where[Op.or] = [
        { merchant_name: { [Op.iLike]: `%${search}%` } },
        { description: { [Op.iLike]: `%${search}%` } },
      ];
    }

    const transactions = await Transaction.findAll({
      where,
      order: [['transaction_date', 'DESC']],
      limit: Math.min(parseInt(String(limit)) || 50, 200),
      offset: parseInt(String(offset)) || 0,
    });

    res.json(transactions);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch transactions', details: error.message });
  }
});

// NEW: Add a credit card
app.post('/api/v1/users/:userId/cards', async (req, res) => {
  try {
    const { userId } = req.params;
    const { cardName, issuer, last4, rewardProgram, availableCredit } = req.body;

    const card = await CreditCard.create({
      user_id: userId,
      card_name: cardName,
      issuer,
      last_4: last4,
      reward_program: rewardProgram,
      available_credit: availableCredit,
    });

    res.status(201).json(card);
  } catch (error) {
    res.status(500).json({ error: 'Failed to create card', details: error.message });
  }
});

app.listen(port, () => {
  console.log(`Server listening on http://localhost:${port}`);
});
