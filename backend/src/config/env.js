const dotenv = require('dotenv');

// Charger les variables d'environnement
dotenv.config();

module.exports = {
    PORT: process.env.PORT || 5000,
    NODE_ENV: process.env.NODE_ENV || 'development',
    MONGO_URI: process.env.MONGO_URI,
    JWT_SECRET: process.env.JWT_SECRET || 'secretcalinlink123',
    SMTP_USER: process.env.SMTP_USER,

};
