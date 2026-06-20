const jwt = require('jsonwebtoken');
const userRepository = require('../../users/repositories/userRepository');
const sendEmail = require('../../../shared/utils/sendEmail');
const CustomError = require('../../../core/errors/customError');

class AuthService {
    generateToken(id) {
        return jwt.sign({ id }, process.env.JWT_SECRET || 'secretcalinlink123', {
            expiresIn: '30d',
        });
    }

    async register(userData) {
        const { firstName, lastName, email, password } = userData;
        const passwordRegex = /^(?=.*[A-Z])(?=.*[0-9]).{8,}$/;

        if (!passwordRegex.test(password)) {
            throw new CustomError('Le mot de passe doit contenir une majuscule, un chiffre et au moins 8 caractères', 400);
        }

        const userExists = await userRepository.findByEmail(email);
        if (userExists) {
            throw new CustomError('Cet utilisateur existe déjà', 400);
        }

        const user = await userRepository.create({
            firstName,
            lastName,
            email,
            password
        });

        if (!user) {
            throw new CustomError('Données utilisateur invalides', 400);
        }

        return {
            _id: user._id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            token: this.generateToken(user._id),
        };
    }

    async login(email, password) {
        const user = await userRepository.findByEmail(email);

        if (!user || !(await user.matchPassword(password))) {
            throw new CustomError('Email ou mot de passe incorrect', 401);
        }

        return {
            _id: user._id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            token: this.generateToken(user._id),
        };
    }

    async forgotPassword(email) {
        const user = await userRepository.findByEmail(email);

        if (!user) {
            throw new CustomError('Aucun compte associé à cet email.', 404);
        }

        const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
        user.resetPasswordCode = resetCode;
        user.resetPasswordExpires = Date.now() + 15 * 60 * 1000;

        await userRepository.save(user);

        const message = `Bonjour ${user.firstName},\n\nVous avez demandé à réinitialiser votre mot de passe.\n\nVoici votre code de sécurité à 6 chiffres : ${resetCode}\n\nCe code expirera dans 15 minutes.\n\nSi vous n'avez pas fait cette demande, ignorez cet email.`;

        if (!process.env.SMTP_USER || process.env.SMTP_USER === '') {
            console.log(`\n\n======================================================`);
            console.log(`[DEV ONLY] Simulation d'email pour ${user.email}`);
            console.log(`CODE DE SÉCURITÉ : ${resetCode}`);
            console.log(`======================================================\n\n`);
            return { message: 'Code envoyé (simulé en console).' };
        }

        try {
            await sendEmail({
                email: user.email,
                subject: 'Réinitialisation de votre mot de passe CâlinLink',
                message
            });
            return { message: 'Code envoyé par email.' };
        } catch (error) {
            user.resetPasswordCode = undefined;
            user.resetPasswordExpires = undefined;
            await userRepository.save(user);
            throw new CustomError("Erreur lors de l'envoi de l'email.", 500);
        }
    }

    async verifyResetCode(email, code) {
        // Need a direct Mongoose call here because we need specific conditions, or use generic query in repository
        // I will use generic query in repository: wait, userRepository doesn't have it.
        // Let's do it via findByEmail then check conditions.
        const user = await userRepository.findByEmail(email);
        
        if (!user || user.resetPasswordCode !== code || user.resetPasswordExpires < Date.now()) {
            throw new CustomError('Code invalide ou expiré.', 400);
        }

        const resetToken = jwt.sign({ id: user._id }, process.env.JWT_SECRET || 'secretcalinlink123', {
            expiresIn: '10m',
        });

        return { message: 'Code vérifié avec succès.', resetToken };
    }

    async resetPassword(resetToken, newPassword) {
        const passwordRegex = /^(?=.*[A-Z])(?=.*[0-9]).{6,}$/;
        if (!passwordRegex.test(newPassword)) {
            throw new CustomError('Le mot de passe doit contenir une majuscule, un chiffre et au moins 6 caractères', 400);
        }

        let decoded;
        try {
            decoded = jwt.verify(resetToken, process.env.JWT_SECRET || 'secretcalinlink123');
        } catch (error) {
            throw new CustomError('Token invalide ou expiré.', 500);
        }

        const user = await userRepository.findById(decoded.id);

        if (!user) {
            throw new CustomError('Utilisateur non trouvé.', 404);
        }

        user.password = newPassword;
        user.resetPasswordCode = undefined;
        user.resetPasswordExpires = undefined;

        await userRepository.save(user);

        return { message: 'Mot de passe réinitialisé.' };
    }
}

module.exports = new AuthService();
