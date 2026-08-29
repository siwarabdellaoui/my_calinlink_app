// =========================================================
// IMPORTATIONS
// =========================================================

const http = require('http');
const dotenv = require('dotenv');

const connectDB =
    require('./infrastructure/database/db');

const app =
    require('./app');

const initSocketIO =
    require('./infrastructure/websocket/socketServer');

const { initMQTT } =
    require('./infrastructure/mqtt/mqttService');


// =========================================================
// VARIABLES D'ENVIRONNEMENT
// =========================================================

dotenv.config();


// =========================================================
// CONNEXION MONGODB
// =========================================================

connectDB();


// =========================================================
// SERVEUR HTTP
// =========================================================

const server = http.createServer(app);


// =========================================================
// SOCKET.IO
// =========================================================

const io = initSocketIO(server);


// =========================================================
// MQTT
// =========================================================

initMQTT(io);


// =========================================================
// PORT
// =========================================================

const PORT =
    process.env.PORT || 5000;


// =========================================================
// DÉMARRAGE SERVEUR
// =========================================================

server.listen(PORT, () => {

    console.log('');
    console.log('========================================');
    console.log('       CÂLINLINK BACKEND');
    console.log('========================================');

    console.log(
        `Serveur CâlinLink démarré en mode ${
            process.env.NODE_ENV || 'développement'
        } sur le port ${PORT}`
    );

    console.log(
        'API : http://localhost:' + PORT
    );

    console.log('========================================');
    console.log('');
});