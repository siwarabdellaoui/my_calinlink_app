const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        // Optionnel : URL par défaut si le .env n'est pas configuré
        const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/calinlink_test';

        const conn = await mongoose.connect(uri);

        console.log(`MongoDB Connecté : ${conn.connection.host}`);
    } catch (error) {
        console.error(`Erreur de connexion MongoDB : ${error.message}`);
        process.exit(1);
    }
};

module.exports = connectDB;
