const logger = require('../config/logger');

const processEmailQueue = () => {
    logger.info('Vérification de la file d\'attente des emails...');
    // Logique pour traiter les emails en arrière-plan
};

module.exports = processEmailQueue;
