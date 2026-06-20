const dataService = require('../services/dataService');

// @desc    Obtenir l'historique des données du capteur du lit
// @route   GET /api/data/sensors/:deviceId
// @access  Private
const getSensorData = async (req, res) => {
    try {
        const data = await dataService.getSensorData(req.user._id, req.params.deviceId);
        res.json(data);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Obtenir les alertes de l'utilisateur
// @route   GET /api/data/alerts
// @access  Private
const getAlerts = async (req, res) => {
    try {
        const alerts = await dataService.getAlerts(req.user._id);
        res.json(alerts);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Marquer une alerte comme lue
// @route   PUT /api/data/alerts/:id/read
// @access  Private
const markAlertAsRead = async (req, res) => {
    try {
        const alert = await dataService.markAlertAsRead(req.user._id, req.params.id);
        res.json(alert);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// (Optionnel) Pour tester, une route qui génère de la donnée factice (comme si le lit postait)
// @desc    Simuler une donnée envoyée par le lit (Interne/Debug)
// @route   POST /api/data/sensors/mock/:deviceId
// @access  Public (juste pour le prototype)
const mockSensorData = async (req, res) => {
    try {
        const newData = await dataService.mockSensorData(req.params.deviceId, req.body);
        res.status(201).json(newData);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

module.exports = {
    getSensorData,
    getAlerts,
    markAlertAsRead,
    mockSensorData
};
