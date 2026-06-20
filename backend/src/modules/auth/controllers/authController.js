const authService = require('../services/authService');

// @desc    Enregistrer un nouvel utilisateur
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res) => {
    try {
        const result = await authService.register(req.body);
        res.status(201).json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Authentifier un utilisateur & get token
// @route   POST /api/auth/login
// @access  Public
const authUser = async (req, res) => {
    try {
        const result = await authService.login(req.body.email, req.body.password);
        res.json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Générer et envoyer le code OTP pour MP oublié
// @route   POST /api/auth/forgot-password
// @access  Public
const forgotPassword = async (req, res) => {
    try {
        const result = await authService.forgotPassword(req.body.email);
        res.status(200).json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Vérifier le code OTP
// @route   POST /api/auth/verify-reset-code
// @access  Public
const verifyResetCode = async (req, res) => {
    try {
        const result = await authService.verifyResetCode(req.body.email, req.body.code);
        res.status(200).json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

// @desc    Créer le nouveau mot de passe
// @route   POST /api/auth/reset-password
// @access  Public
const resetPassword = async (req, res) => {
    try {
        const result = await authService.resetPassword(req.body.resetToken, req.body.newPassword);
        res.status(200).json(result);
    } catch (error) {
        res.status(error.statusCode || 500).json({ message: error.message });
    }
};

module.exports = {
    registerUser,
    authUser,
    forgotPassword,
    verifyResetCode,
    resetPassword
};
