const env = require('./env');

const serverConfig = {
    port: env.PORT,
    environment: env.NODE_ENV,
    corsOptions: {
        origin: '*', // À configurer pour la production
        methods: ['GET', 'POST', 'PUT', 'DELETE'],
    }
};

module.exports = serverConfig;
