const express = require('express');
const cors = require('cors');

// Importation des routes
const authRoutes = require('./modules/auth/routes/authRoutes');
const userRoutes = require('./modules/users/routes/userRoutes');
const deviceRoutes = require('./modules/devices/routes/deviceRoutes');
const dataRoutes = require('./modules/data/routes/dataRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Routes de base pour tester
app.get('/', (req, res) => {
    res.json({ message: 'Bienvenue sur l\'API CâlinLink ! Le serveur fonctionne 🎉' });
});

// Montage des routes de l'API
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/devices', deviceRoutes);
app.use('/api/data', dataRoutes);

module.exports = app;
