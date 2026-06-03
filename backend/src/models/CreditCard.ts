import { DataTypes } from 'sequelize';

export default (sequelize) => {
  const CreditCard = sequelize.define(
    'CreditCard',
    {
      id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      user_id: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
        onDelete: 'CASCADE',
      },
      card_name: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      issuer: {
        type: DataTypes.STRING(100),
        allowNull: false,
      },
      last_4: {
        type: DataTypes.STRING(4),
        allowNull: false,
      },
      reward_program: {
        type: DataTypes.STRING(100),
      },
      current_balance: {
        type: DataTypes.DECIMAL(12, 2),
        defaultValue: 0,
      },
      available_credit: {
        type: DataTypes.DECIMAL(12, 2),
        defaultValue: 0,
      },
      due_date: {
        type: DataTypes.DATEONLY,
      },
      monthly_spend: {
        type: DataTypes.DECIMAL(12, 2),
        defaultValue: 0,
      },
    },
    {
      tableName: 'credit_cards',
      timestamps: true,
      underscored: true,
      uniqueKeys: {
        unique_card_per_user: {
          fields: ['user_id', 'last_4'],
        },
      },
    }
  );

  return CreditCard;
};
