import { Router } from 'express';

const router = Router();

router.get('/', (req, res) => {
  const cards = [
    {
      id: '1',
      issuer: 'HDFC',
      cardName: 'Millenia',
      last4: '1234',
      rewardProgram: 'SmartPoints',
      currentBalance: 15420.5,
      availableCredit: 34579.5,
      dueDate: new Date(Date.now() + 5 * 24 * 3600 * 1000).toISOString(),
      monthlySpend: 3740,
    },
    {
      id: '2',
      issuer: 'SBI',
      cardName: 'Elite',
      last4: '5678',
      rewardProgram: 'Cashback',
      currentBalance: 8200,
      availableCredit: 12100,
      dueDate: new Date(Date.now() + 12 * 24 * 3600 * 1000).toISOString(),
      monthlySpend: 6200,
    },
  ];

  res.send({
    summary: {
      totalCards: cards.length,
      monthlySpend: cards.reduce((sum, card) => sum + card.monthlySpend, 0),
      totalRewards: 12450,
      nextPaymentDue: cards[0].dueDate,
      nextRedemptionHint: 'Use HDFC Miles for travel',
    },
    cards,
    spendCategories: [
      { name: 'Dining', amount: 6200, color: '#FF9F1C', percent: 37 },
      { name: 'Travel', amount: 4200, color: '#2EC4B6', percent: 25 },
      { name: 'Groceries', amount: 3600, color: '#8D99AE', percent: 21 },
      { name: 'Shopping', amount: 2400, color: '#EF476F', percent: 17 },
    ],
  });
});

export default router;
