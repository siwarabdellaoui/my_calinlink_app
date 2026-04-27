const express = require('express');
const http = require('http');
const cors = require('cors');
const { Server } = require('socket.io');
const dotenv = require('dotenv');
const connectDB = require('./config/db');

// Importation des routes
const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const deviceRoutes = require('./routes/deviceRoutes');
const dataRoutes = require('./routes/dataRoutes');

// Charger les variables d'environnement
dotenv.config();

// Connexion à la base de données
connectDB();

const app = express();
const server = http.createServer(app);

// Configuration de Socket.io pour les temps réels
const io = new Server(server, {
    cors: {
        origin: '*', // En production, on limitera à l'URL de l'application
        methods: ['GET', 'POST']
    }
});

// Middleware
app.use(cors());
app.use(express.json()); // Permet de parser le JSON dans les requêtes API

// Routes de base pour tester
app.get('/', (req, res) => {
    res.json({ message: 'Bienvenue sur l\'API CâlinLink ! Le serveur fonctionne 🎉' });
});

// Montage des routes de l'API
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/devices', deviceRoutes);
app.use('/api/data', dataRoutes);

// Logique temps réel avec Socket.io
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

const PORT = process.env.PORT || 5000;

server.listen(PORT, () => {
    console.log(`Serveur CâlinLink démarré en mode ${process.env.NODE_ENV || 'développement'} sur le port ${PORT}`);
});
