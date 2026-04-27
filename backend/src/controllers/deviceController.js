const Device = require('../models/Device');
const User = require('../models/User');

// @desc    Lier un nouvel appareil au compte courant
// @route   POST /api/devices
// @access  Private
const linkDevice = async (req, res) => {
    const { deviceId, name } = req.body;

    try {
        const deviceExists = await Device.findOne({ deviceId });

        if (deviceExists) {
            return res.status(400).json({ message: 'Cet appareil est déjà enregistré.' });
        }

        const device = await Device.create({
            deviceId,
            owner: req.user._id,
            name: name || 'Lit Bébé CâlinLink'
        });

        // Ajouter l'ID du device à l'utilisateur
        await User.findByIdAndUpdate(req.user._id, { $push: { devices: device._id } });

        res.status(201).json(device);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Obtenir les appareils de l'utilisateur
// @route   GET /api/devices
// @access  Private
const getMyDevices = async (req, res) => {
    try {
        const devices = await Device.find({ 
            $or: [
                { owner: req.user._id },
                { sharedWith: req.user._id }
            ]
        });
        res.json(devices);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Mettre à jour l'état de l'appareil (ex: Allumer berceuse)
// @route   PUT /api/devices/:id/status
// @access  Private
const updateDeviceStatus = async (req, res) => {
    try {
        const device = await Device.findById(req.params.id);

        if (!device) {
            return res.status(404).json({ message: 'Appareil non trouvé' });
        }

        const isOwner = device.owner.toString() === req.user._id.toString();
        const isShared = device.sharedWith && device.sharedWith.includes(req.user._id);

        if (!isOwner && !isShared) {
            return res.status(401).json({ message: 'Non autorisé à modifier cet appareil' });
        }

        // Mettre à jour l'état spécifié
        if (req.body.isBerceuseEnabled !== undefined) {
            device.status.isBerceuseEnabled = req.body.isBerceuseEnabled;
        }
        if (req.body.isDouceNuitEnabled !== undefined) {
            device.status.isDouceNuitEnabled = req.body.isDouceNuitEnabled;
        }

        const updatedDevice = await device.save();
        res.json(updatedDevice);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Partager un appareil
// @route   POST /api/devices/share
// @access  Private
const shareDevice = async (req, res) => {
    try {
        const { email } = req.body;

        // 1. Chercher l'utilisateur invité
        const invitedUser = await User.findOne({ email });
        if (!invitedUser) {
            return res.status(404).json({ message: "Aucun utilisateur trouvé avec cet email." });
        }

        if (invitedUser._id.toString() === req.user._id.toString()) {
            return res.status(400).json({ message: "Vous ne pouvez pas partager un appareil avec vous-même." });
        }

        // 2. Trouver le lit (On prend le premier lit du propriétaire)
        const device = await Device.findOne({ owner: req.user._id });
        if (!device) {
            return res.status(404).json({ message: "Vous n'avez pas de lit à partager." });
        }

        // 3. Vérifier s'il est déjà partagé
        if (device.sharedWith && device.sharedWith.includes(invitedUser._id)) {
            return res.status(400).json({ message: "Cet utilisateur a déjà accès au lit." });
        }

        // 4. Ajouter l'utilisateur
        device.sharedWith.push(invitedUser._id);
        await device.save();

        // 5. Ajouter le lit à la liste des lits de l'utilisateur
        await User.findByIdAndUpdate(invitedUser._id, { $push: { devices: device._id } });

        res.status(200).json({ message: "Accès partagé avec succès !" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    linkDevice,
    getMyDevices,
    updateDeviceStatus,
    shareDevice
};
