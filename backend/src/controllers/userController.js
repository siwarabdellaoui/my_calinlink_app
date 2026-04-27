const User = require('../models/User');
const sendEmail = require('../utils/sendEmail');

// @desc    Obtenir le profil utilisateur
// @route   GET /api/users/profile
// @access  Private
const getUserProfile = async (req, res) => {
    const user = await User.findById(req.user._id);

    if (user) {
        res.json({
            _id: user._id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phone: user.phone,
            avatar: user.avatar,
            babyContext: user.babyContext,
            devices: user.devices
        });
    } else {
        res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
};

// @desc    Mettre à jour le profil utilisateur
// @route   PUT /api/users/profile
// @access  Private
const updateUserProfile = async (req, res) => {
    const user = await User.findById(req.user._id);

    if (user) {
        user.firstName = req.body.firstName || user.firstName;
        user.lastName = req.body.lastName || user.lastName;
        user.phone = req.body.phone || user.phone;
        
        if (req.body.avatar) {
            user.avatar = req.body.avatar;
        }
        
        if (req.body.password) {
            user.password = req.body.password;
        }

        if (req.body.babyContext) {
            user.babyContext.firstName = req.body.babyContext.firstName || user.babyContext.firstName;
            user.babyContext.birthDate = req.body.babyContext.birthDate || user.babyContext.birthDate;
            user.babyContext.gender = req.body.babyContext.gender || user.babyContext.gender;
        }

        const updatedUser = await user.save();

        res.json({
            _id: updatedUser._id,
            firstName: updatedUser.firstName,
            lastName: updatedUser.lastName,
            email: updatedUser.email,
            phone: updatedUser.phone,
            avatar: updatedUser.avatar,
            babyContext: updatedUser.babyContext
        });
    } else {
        res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
};

// @desc    Déconnecter de tous les appareils
// @route   POST /api/users/logout-all
// @access  Private
const logoutAllDevices = async (req, res) => {
    const user = await User.findById(req.user._id);

    if (user) {
        user.sessionsValidAfter = new Date();
        await user.save();
        res.json({ message: 'Déconnecté de tous les autres appareils' });
    } else {
        res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
};

// @desc    Générer un OTP et envoyer par email pour confirmer le changement de MdP
// @route   POST /api/users/change-password-request
// @access  Private
const requestPasswordChange = async (req, res) => {
    const { oldPassword } = req.body;
    const user = await User.findById(req.user._id);

    if (!user) {
        return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    // Vérifier l'ancien mot de passe
    if (!(await user.matchPassword(oldPassword))) {
        return res.status(401).json({ message: 'Ancien mot de passe incorrect' });
    }

    // Générer OTP
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    user.changePasswordCode = resetCode;
    user.changePasswordExpires = Date.now() + 15 * 60 * 1000;

    await user.save();

    const message = `Bonjour ${user.firstName},\n\nVous avez demandé à changer votre mot de passe depuis l'application.\nVoici votre code de sécurité : ${resetCode}\nValable pendant 15 minutes.`;

    if (!process.env.SMTP_USER || process.env.SMTP_USER === '') {
        console.log(`[DEV ONLY] Simulation d'email de changement MdP pour ${user.email} - CODE: ${resetCode}`);
        return res.status(200).json({ message: 'Code envoyé (simulé).' });
    }

    try {
        await sendEmail({ email: user.email, subject: 'Changement de votre mot de passe', message });
        res.status(200).json({ message: 'Code envoyé par email.' });
    } catch (error) {
        user.changePasswordCode = undefined;
        user.changePasswordExpires = undefined;
        await user.save();
        res.status(500).json({ message: "Erreur lors de l'envoi de l'email." });
    }
};

// @desc    Vérifier OTP et changer mot de passe, suivi de la déconnexion
// @route   POST /api/users/change-password-verify
// @access  Private
const verifyPasswordChange = async (req, res) => {
    const { code, newPassword } = req.body;
    const user = await User.findById(req.user._id);

    if (!user) {
        return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    // Vérification du code
    if (user.changePasswordCode !== code || user.changePasswordExpires < Date.now()) {
        return res.status(400).json({ message: 'Code invalide ou expiré' });
    }

    // Mise à jour
    user.password = newPassword;
    user.changePasswordCode = undefined;
    user.changePasswordExpires = undefined;
    user.sessionsValidAfter = new Date(); // Invalide les anciens tokens (déconnexion de tous les appareils)

    await user.save();
    res.json({ message: 'Mot de passe mis à jour et déconnecté des autres appareils.' });
};

module.exports = {
    getUserProfile,
    updateUserProfile,
    logoutAllDevices,
    requestPasswordChange,
    verifyPasswordChange
};
