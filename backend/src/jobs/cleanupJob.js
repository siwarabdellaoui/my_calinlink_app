// Exemple de job (peut utiliser node-cron ou setInterval)
const logger = require('../config/logger');

const runCleanupJob = () => {
    logger.info('Exécution du Cleanup Job : Nettoyage des anciennes données...');
    // Logique de nettoyage de la base de données ici
};

// Exécuter toutes les 24 heures par exemple
// setInterval(runCleanupJob, 24 * 60 * 60 * 1000);

module.exports = runCleanupJob;
