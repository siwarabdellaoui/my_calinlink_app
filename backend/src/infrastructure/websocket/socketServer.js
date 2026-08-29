const { Server } = require('socket.io');
const { publishMQTT } = require('../mqtt/mqttService');

const initSocketIO = (server) => {
    const io = new Server(server, {
        cors: {
            origin: '*', // En production, on limitera à l'URL de l'application
            methods: ['GET', 'POST']
        }
    });

    io.on('connection', (socket) => {
        console.log(`Nouvel équipement connecté : ${socket.id}`);
        
        // Exemple : Le lit envoie une nouvelle température
        socket.on('sensorUpdate', (data) => {
            // On transfère l'info immédiatement à l'application mobile
            io.emit('newSensorData', data); 
        });

        // Intercepter les commandes de Flutter et les renvoyer en MQTT
        socket.on('calinlink:cmd', (data) => {
            console.log('Commande reçue de l\'application Flutter :', data);
            if (data && data.action) {
                const topic = `calinlink/commande/${data.action}`;
                let payload;
                if (typeof data.value === 'boolean') {
                    payload = data.value ? '1' : '0';
                } else {
                    payload = String(data.value);
                }
                publishMQTT(topic, payload);
            }
        });

        socket.on('disconnect', () => {
            console.log(`Équipement déconnecté : ${socket.id}`);
        });
    });

    return io;
};

module.exports = initSocketIO;
