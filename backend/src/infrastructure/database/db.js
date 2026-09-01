const mongoose = require('mongoose');
const User = require('../../modules/users/models/User');

const connectDB = async () => {
    try {
        // Optionnel : URL par défaut si le .env n'est pas configuré
        const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/calinlink_test';

        const conn = await mongoose.connect(uri);

        console.log(`MongoDB Connecté : ${conn.connection.host}`);

        // Créer l'utilisateur test maman@calinlink.fr s'il n'existe pas ou initialiser son profil
        const testEmail = 'maman@calinlink.fr';
        let userExists = await User.findOne({ email: testEmail });
        if (!userExists) {
            await User.create({
                firstName: 'Maman',
                lastName: 'CâlinLink',
                email: testEmail,
                password: 'Password123',
                phone: '+33 6 12 34 56 78',
                babyContext: {
                    firstName: 'Léo',
                    birthDate: new Date('2024-10-04'),
                    gender: 'M'
                }
            });
            console.log(`Utilisateur de test ${testEmail} créé avec succès.`);
        } else if (!userExists.babyContext || !userExists.babyContext.firstName) {
            userExists.phone = userExists.phone || '+33 6 12 34 56 78';
            if (!userExists.babyContext) userExists.babyContext = {};
            userExists.babyContext.firstName = userExists.babyContext.firstName || 'Léo';
            userExists.babyContext.birthDate = userExists.babyContext.birthDate || new Date('2024-10-04');
            userExists.babyContext.gender = userExists.babyContext.gender || 'M';
            userExists.markModified('babyContext');
            await userExists.save();
            console.log(`Données de test pour ${testEmail} initialisées avec succès.`);
        }
    } catch (error) {
        console.error(`Erreur de connexion MongoDB : ${error.message}`);
        process.exit(1);
    }
};

module.exports = connectDB;
