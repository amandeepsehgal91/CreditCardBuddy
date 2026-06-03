import { DataTypes } from 'sequelize';

export default (sequelize) => {
  const Transaction = sequelize.define(
    'Transaction',
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      card_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'credit_cards',
          key: 'id',
        },
        onDelete: 'CASCADE',
      },
      merchant_name: {
        type: DataTypes.STRING(255),
        allowNull: false,
      },
      category: {
        type: DataTypes.STRING(100),
      },
      amount: {
        type: DataTypes.DECIMAL(12, 2),
        allowNull: false,
      },
      transaction_date: {
        type: DataTypes.DATEONLY,
        allowNull: false,
      },
      description: {
        type: DataTypes.TEXT,
      },
      status: {
        type: DataTypes.STRING(50),
        defaultValue: 'completed',
      },
    },
    {
      tableName: 'transactions',
      timestamps: true,
      underscored: true,
      indexes: [
        {
          fields: ['card_id'],
        },
        {
          fields: ['transaction_date'],
        },
      ],
    }
  );

  return Transaction;
};
