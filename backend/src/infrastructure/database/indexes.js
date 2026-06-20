// Fichier pour la configuration des index MongoDB
// Utile pour s'assurer que les index sont créés (ex: email unique, TTL pour les OTP)
const User = require('../../../modules/users/models/User');
// const Otp = require('../../../modules/auth/models/Otp');

const ensureIndexes = async () => {
    try {
        await User.syncIndexes();
        // await Otp.syncIndexes();
        console.log('Index MongoDB synchronisés avec succès.');
    } catch (error) {
        console.error('Erreur lors de la synchronisation des index:', error);
    }
};

module.exports = ensureIndexes;
