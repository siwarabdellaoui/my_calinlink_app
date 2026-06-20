// Configuration de la file d'attente (RabbitMQ, BullMQ, ou SQS)
// const Queue = require('bull');

/*
const emailQueue = new Queue('email-queue', process.env.REDIS_URL);

emailQueue.process(async (job) => {
    // Traitement de l'email
});
*/

const jobQueue = {
    addJob: (jobName, data) => {
        console.log(`[Mock Queue] Ajout du job ${jobName} dans la file d'attente`);
    }
};

module.exports = jobQueue;
