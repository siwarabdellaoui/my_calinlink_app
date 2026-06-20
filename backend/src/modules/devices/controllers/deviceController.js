const deviceService = require('../services/deviceService');

// @desc    Lier un nouvel appareil au compte courant
// @route   POST /api/devices
// @access  Private
const linkDevice = async (req, res) => {
    try {
        const { deviceId, name } = req.body;
        const result = await deviceService.linkDevice(req.user._id, deviceId, name);
        res.status(201).json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Obtenir les appareils de l'utilisateur
// @route   GET /api/devices
// @access  Private
const getMyDevices = async (req, res) => {
    try {
        const devices = await deviceService.getMyDevices(req.user._id);
        res.json(devices);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Mettre à jour l'état de l'appareil (ex: Allumer berceuse)
// @route   PUT /api/devices/:id/status
// @access  Private
const updateDeviceStatus = async (req, res) => {
    try {
        const result = await deviceService.updateDeviceStatus(req.user._id, req.params.id, req.body);
        res.json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Partager un appareil
// @route   POST /api/devices/share
// @access  Private
const shareDevice = async (req, res) => {
    try {
        const result = await deviceService.shareDevice(req.user._id, req.body.email);
        res.status(200).json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

module.exports = {
    linkDevice,
    getMyDevices,
    updateDeviceStatus,
    shareDevice
};
