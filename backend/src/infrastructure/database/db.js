const dns = require('dns');
const mongoose = require('mongoose');
const User = require('../../modules/users/models/User');

// Configuration des serveurs DNS pour résoudre les enregistrements SRV de MongoDB Atlas
// Cela résout l'erreur querySrv ECONNREFUSED sur Windows / réseaux locaux
try {
    dns.setServers(['8.8.8.8', '8.8.4.4', '1.1.1.1']);
} catch (e) {
    console.warn('Note: Impossible de définir les serveurs DNS personnalisés:', e.message);
}

async function seedDefaultUser() {
    try {
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
    } catch (e) {
        console.warn('Note lors de l\'initialisation du profil test:', e.message);
    }
}

const connectDB = async () => {
    let uri = (process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/calinlink_test').trim();
    if (uri.startsWith('MONGO_URI=')) {
        uri = uri.replace(/^MONGO_URI=/, '').trim();
    }

    try {
        const conn = await mongoose.connect(uri, {
            serverSelectionTimeoutMS: 5000,
        });

        console.log(`MongoDB Connecté : ${conn.connection.host}`);
        await seedDefaultUser();
    } catch (error) {
        console.error(`Erreur de connexion MongoDB : ${error.message}`);

        // Tentative de fallback sur MongoDB local si Atlas échoue
        if (uri.includes('mongodb+srv://') || uri.includes('mongodb.net')) {
            console.log('Tentative de connexion de secours sur MongoDB local (127.0.0.1:27017)...');
            try {
                const localConn = await mongoose.connect('mongodb://127.0.0.1:27017/calinlink_test', {
                    serverSelectionTimeoutMS: 3000,
                });
                console.log(`MongoDB Local Connecté : ${localConn.connection.host}`);
                await seedDefaultUser();
                return;
            } catch (localError) {
                console.warn('MongoDB local non disponible.');
            }
        }

        // On ne crashe pas le serveur avec process.exit(1) afin que MQTT et Socket.IO restent actifs
        console.warn('Le serveur CâlinLink reste actif pour le temps réel MQTT/Socket.IO. Nouvelle tentative MongoDB dans 10 secondes...');
        setTimeout(connectDB, 10000);
    }
};

module.exports = connectDB;
