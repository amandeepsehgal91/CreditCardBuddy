import { Sequelize } from 'sequelize';
import UserModel from './User';
import CreditCardModel from './CreditCard';
import TransactionModel from './Transaction';

const sequelize = new Sequelize(
  process.env.DB_NAME || 'credit_card_buddy',
  process.env.DB_USER || 'postgres',
  process.env.DB_PASSWORD || 'password',
  {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    dialect: 'postgres',
    logging: process.env.NODE_ENV === 'development' ? console.log : false,
  }
);

// Initialize models
const User = UserModel(sequelize);
const CreditCard = CreditCardModel(sequelize);
const Transaction = TransactionModel(sequelize);

// Define associations
User.hasMany(CreditCard, { foreignKey: 'user_id', as: 'cards' });
CreditCard.belongsTo(User, { foreignKey: 'user_id' });

CreditCard.hasMany(Transaction, { foreignKey: 'card_id', as: 'transactions' });
Transaction.belongsTo(CreditCard, { foreignKey: 'card_id' });

// Export models and sequelize instance
export { sequelize, User, CreditCard, Transaction };

// Sync database (development only)
export async function syncDatabase() {
  try {
    await sequelize.authenticate();
    console.log('Database connection established.');
    
    if (process.env.NODE_ENV === 'development') {
      await sequelize.sync({ alter: true });
      console.log('Database synced.');
    }
  } catch (error) {
    console.error('Unable to connect to the database:', error);
    process.exit(1);
  }
}
