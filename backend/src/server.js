const http = require('http');
const dotenv = require('dotenv');
const connectDB = require('./infrastructure/database/db');
const app = require('./app');
const initSocketIO = require('./infrastructure/websocket/socketServer');

// Charger les variables d'environnement
dotenv.config();

// Connexion à la base de données
connectDB();

const server = http.createServer(app);

// Initialisation de Socket.io
initSocketIO(server);

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
    console.log(`Serveur CâlinLink démarré en mode ${process.env.NODE_ENV || 'développement'} sur le port ${PORT}`);
});
