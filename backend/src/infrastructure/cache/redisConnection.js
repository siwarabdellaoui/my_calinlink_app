// Configuration de la connexion Redis (si utilisé pour le cache)
// const redis = require('redis');

const connectRedis = async () => {
    /*
    const client = redis.createClient({ url: process.env.REDIS_URL });
    client.on('error', (err) => console.log('Redis Client Error', err));
    await client.connect();
    console.log('Connecté à Redis');
    return client;
    */
    console.log('[Mock] Connexion au Cache Redis non initialisée');
    return null;
};

module.exports = connectRedis;
