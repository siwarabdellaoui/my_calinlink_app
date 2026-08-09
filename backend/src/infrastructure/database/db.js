const mongoose = require('mongoose');
const User = require('../../modules/users/models/User');

const connectDB = async () => {
    try {
        // Optionnel : URL par défaut si le .env n'est pas configuré
        const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/calinlink_test';

        const conn = await mongoose.connect(uri);

        console.log(`MongoDB Connecté : ${conn.connection.host}`);

        // Créer l'utilisateur test maman@calinlink.fr s'il n'existe pas
        const testEmail = 'maman@calinlink.fr';
        const userExists = await User.findOne({ email: testEmail });
        if (!userExists) {
            await User.create({
                firstName: 'Maman',
                lastName: 'CâlinLink',
                email: testEmail,
                password: 'Password123'
            });
            console.log(`Utilisateur de test ${testEmail} créé avec succès.`);
        }
    } catch (error) {
        console.error(`Erreur de connexion MongoDB : ${error.message}`);
        process.exit(1);
    }
};

module.exports = connectDB;
