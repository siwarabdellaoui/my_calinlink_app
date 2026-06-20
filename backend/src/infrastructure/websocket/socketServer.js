const { Server } = require('socket.io');

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

        socket.on('disconnect', () => {
            console.log(`Équipement déconnecté : ${socket.id}`);
        });
    });

    return io;
};

module.exports = initSocketIO;
