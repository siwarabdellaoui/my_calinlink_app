const SensorData = require('../models/SensorData');
const Alert = require('../models/Alert');
const Device = require('../models/Device');

// @desc    Obtenir l'historique des données du capteur du lit
// @route   GET /api/data/sensors/:deviceId
// @access  Private
const getSensorData = async (req, res) => {
    try {
        const dId = req.params.deviceId;
        
        // Vérifier d'abord que ce device appartient bien au user (pour la sécurité)
        const device = await Device.findById(dId);
        if (!device || device.owner.toString() !== req.user._id.toString()) {
            return res.status(401).json({ message: 'Non autorisé à voir ces données' });
        }

        // On limite à 100 dernières valeurs pour les graphiques
        const data = await SensorData.find({ device: dId })
                                     .sort({ timestamp: -1 })
                                     .limit(100);
        res.json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Obtenir les alertes de l'utilisateur
// @route   GET /api/data/alerts
// @access  Private
const getAlerts = async (req, res) => {
    try {
        const alerts = await Alert.find({ user: req.user._id }).sort({ createdAt: -1 });
        res.json(alerts);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Marquer une alerte comme lue
// @route   PUT /api/data/alerts/:id/read
// @access  Private
const markAlertAsRead = async (req, res) => {
    try {
        const alert = await Alert.findById(req.params.id);

        if (!alert || alert.user.toString() !== req.user._id.toString()) {
            return res.status(404).json({ message: 'Alerte non trouvée' });
        }

        alert.isRead = true;
        await alert.save();
        res.json(alert);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// (Optionnel) Pour tester, une route qui génère de la donnée factice (comme si le lit postait)
// @desc    Simuler une donnée envoyée par le lit (Interne/Debug)
// @route   POST /api/data/sensors/mock/:deviceId
// @access  Public (juste pour le prototype)
const mockSensorData = async (req, res) => {
    try {
        const dId = req.params.deviceId;
        const newData = await SensorData.create({
            device: dId,
            temperature: req.body.temperature || (20 + Math.random() * 2), // ~21°C
            humidity: req.body.humidity || (50 + Math.random() * 10), // ~55%
            motionDetected: req.body.motionDetected || false
        });
        res.status(201).json(newData);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getSensorData,
    getAlerts,
    markAlertAsRead,
    mockSensorData
};
