const express = require('express');
const router = express.Router();
const { getSensorData, getAlerts, markAlertAsRead, mockSensorData } = require('../controllers/dataController');
const { protect } = require('../../../shared/middlewares/authMiddleware');// verifie que l'user est connecté

// Routes des capteurs
router.route('/sensors/:deviceId')
    .get(protect, getSensorData);
    
router.post('/sensors/mock/:deviceId', mockSensorData); // Debug, sans auth

// Routes des alertes
router.route('/alerts')
    .get(protect, getAlerts);

router.route('/alerts/:id/read')
    .put(protect, markAlertAsRead);

module.exports = router;
