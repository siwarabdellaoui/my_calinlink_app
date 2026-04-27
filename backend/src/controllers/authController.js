const User = require('../models/User');
const jwt = require('jsonwebtoken'); // permet de créer les token JWT
const crypto = require('crypto');
const sendEmail = require('../utils/sendEmail');

// Générer JWT
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET || 'secretcalinlink123', {
        expiresIn: '30d',
    });
};

// @desc    Enregistrer un nouvel utilisateur
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res) => {
    try {
        const { firstName, lastName, email, password } = req.body;
        const passwordRegex = /^(?=.*[A-Z])(?=.*[0-9]).{8,}$/;

        if (!passwordRegex.test(password)) {
          return res.status(400).json({
            message: 'Le mot de passe doit contenir une majuscule, un chiffre et au moins 6 caractères'
          });
        }
        // Vérication de l'existence
        const userExists = await User.findOne({ email });

        if (userExists) {
            return res.status(400).json({ message: 'Cet utilisateur existe déjà' });
        }

        const user = await User.create({
            firstName,
            lastName,
            email,
            password
        });

        if (user) {
            res.status(201).json({
                _id: user._id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                token: generateToken(user._id),
            });
        } else {
            res.status(400).json({ message: 'Données utilisateur invalides' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Authentifier un utilisateur & get token
// @route   POST /api/auth/login
// @access  Public
const authUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email });

        if (user && (await user.matchPassword(password))) {
            res.json({
                _id: user._id,
                firstName: user.firstName,
                lastName: user.lastName,
                email: user.email,
                token: generateToken(user._id),
            });
        } else {
            res.status(401).json({ message: 'Email ou mot de passe incorrect' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Générer et envoyer le code OTP pour MP oublié
// @route   POST /api/auth/forgot-password
// @access  Public
const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ message: 'Aucun compte associé à cet email.' });
        }

        // Générer un code à 6 chiffres
        const resetCode = Math.floor(100000 + Math.random() * 900000).toString();

        user.resetPasswordCode = resetCode;
        user.resetPasswordExpires = Date.now() + 15 * 60 * 1000; // 15 minutes

        await user.save({ validateBeforeSave: false });

        // Envoi de l'email
        const message = `Bonjour ${user.firstName},\n\nVous avez demandé à réinitialiser votre mot de passe.\n\nVoici votre code de sécurité à 6 chiffres : ${resetCode}\n\nCe code expirera dans 15 minutes.\n\nSi vous n'avez pas fait cette demande, ignorez cet email.`;

        if (!process.env.SMTP_USER || process.env.SMTP_USER === '') {
            // Mode DÉVELOPPEMENT : on simule l'envoi pour ne pas bloquer
            console.log(`\n\n======================================================`);
            console.log(`[DEV ONLY] Simulation d'email pour ${user.email}`);
            console.log(`CODE DE SÉCURITÉ : ${resetCode}`);
            console.log(`======================================================\n\n`);
            return res.status(200).json({ message: 'Code envoyé (simulé en console).' });
        }

        try {
            await sendEmail({
                email: user.email,
                subject: 'Réinitialisation de votre mot de passe CâlinLink',
                message
            });
            console.log(`Email envoyé avec succès à ${user.email}`);

            res.status(200).json({ message: 'Code envoyé par email.' });
        } catch (error) {
            user.resetPasswordCode = undefined;
            user.resetPasswordExpires = undefined;
            await user.save({ validateBeforeSave: false });

            console.error('Erreur envoi email:', error);
            return res.status(500).json({ message: "Erreur lors de l'envoi de l'email." });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Vérifier le code OTP
// @route   POST /api/auth/verify-reset-code
// @access  Public
const verifyResetCode = async (req, res) => {
    try {
        const { email, code } = req.body;
        const user = await User.findOne({
            email,
            resetPasswordCode: code,
            resetPasswordExpires: { $gt: Date.now() }
        });

        if (!user) {
            return res.status(400).json({ message: 'Code invalide ou expiré.' });
        }

        const resetToken = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'secretcalinlink123', {
            expiresIn: '10m', // 10 minutes pour réinitialiser
        });

        res.status(200).json({ message: 'Code vérifié avec succès.', resetToken });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Créer le nouveau mot de passe
// @route   POST /api/auth/reset-password
// @access  Public
const resetPassword = async (req, res) => {
    try {
        const { resetToken, newPassword } = req.body;

        const passwordRegex = /^(?=.*[A-Z])(?=.*[0-9]).{6,}$/;
        if (!passwordRegex.test(newPassword)) {
          return res.status(400).json({
            message: 'Le mot de passe doit contenir une majuscule, un chiffre et au moins 6 caractères'
          });
        }

        const decoded = jwt.verify(resetToken, process.env.JWT_SECRET || 'secretcalinlink123');
        const user = await User.findById(decoded.id);

        if (!user) {
            return res.status(404).json({ message: 'Utilisateur non trouvé.' });
        }

        user.password = newPassword;
        user.resetPasswordCode = undefined;
        user.resetPasswordExpires = undefined;

        await user.save();

        res.status(200).json({ message: 'Mot de passe réinitialisé.' });
    } catch (error) {
        res.status(500).json({ message: 'Token invalide ou expiré.' });
    }
};

module.exports = {
    registerUser,
    authUser,
    forgotPassword,
    verifyResetCode,
    resetPassword
};
