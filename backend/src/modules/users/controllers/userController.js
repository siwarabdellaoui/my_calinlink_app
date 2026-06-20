const userService = require('../services/userService');

// @desc    Obtenir le profil utilisateur
// @route   GET /api/users/profile
// @access  Private
const getUserProfile = async (req, res) => {
    try {
        const profile = await userService.getUserProfile(req.user._id);
        res.json(profile);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Mettre à jour le profil utilisateur
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = async (req, res) => {
    try {
        const updatedProfile = await userService.updateUserProfile(req.user._id, req.body);
        res.json(updatedProfile);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Déconnecter de tous les appareils
// @route   POST /api/users/logout-all
// @access  Private
const logoutAllDevices = async (req, res) => {
    try {
        const result = await userService.logoutAllDevices(req.user._id);
        res.json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Générer un OTP et envoyer par email pour confirmer le changement de MdP
// @route   POST /api/users/change-password-request
// @access  Private
const requestPasswordChange = async (req, res) => {
    try {
        const result = await userService.requestPasswordChange(req.user._id, req.body.oldPassword);
        res.status(200).json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Vérifier OTP et changer mot de passe, suivi de la déconnexion
// @route   POST /api/users/change-password-verify
// @access  Private
const verifyPasswordChange = async (req, res) => {
    try {
        const result = await userService.verifyPasswordChange(req.user._id, req.body.code, req.body.newPassword);
        res.json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

module.exports = {
    getUserProfile,
    updateUserProfile,
    logoutAllDevices,
    requestPasswordChange,
    verifyPasswordChange
};
