const userRepository = require('../repositories/userRepository');
const sendEmail = require('../../../shared/utils/sendEmail');
const CustomError = require('../../../core/errors/customError');

class UserService {
    async getUserProfile(userId) {
        const user = await userRepository.findById(userId);
        if (!user) {
            throw new CustomError('Utilisateur non trouvé', 404);
        }
        return {
            _id: user._id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phone: user.phone,
            avatar: user.avatar,
            babyContext: user.babyContext,
            devices: user.devices
        };
    }

    async updateUserProfile(userId, updateData) {
        const user = await userRepository.findById(userId);
        if (!user) {
            throw new CustomError('Utilisateur non trouvé', 404);
        }

        user.firstName = updateData.firstName || user.firstName;
        user.lastName = updateData.lastName || user.lastName;
        user.phone = updateData.phone || user.phone;
        
        if (updateData.avatar) user.avatar = updateData.avatar;
        if (updateData.password) user.password = updateData.password;

        if (updateData.babyContext) {
            user.babyContext.firstName = updateData.babyContext.firstName || user.babyContext.firstName;
            user.babyContext.birthDate = updateData.babyContext.birthDate || user.babyContext.birthDate;
            user.babyContext.gender = updateData.babyContext.gender || user.babyContext.gender;
        }

        const updatedUser = await userRepository.save(user);

        return {
            _id: updatedUser._id,
            firstName: updatedUser.firstName,
            lastName: updatedUser.lastName,
            email: updatedUser.email,
            phone: updatedUser.phone,
            avatar: updatedUser.avatar,
            babyContext: updatedUser.babyContext
        };
    }

    async logoutAllDevices(userId) {
        const user = await userRepository.findById(userId);
        if (!user) {
            throw new CustomError('Utilisateur non trouvé', 404);
        }
        user.sessionsValidAfter = new Date();
        await userRepository.save(user);
        return { message: 'Déconnecté de tous les autres appareils' };
    }

    async requestPasswordChange(userId, oldPassword) {
        const user = await userRepository.findById(userId);
        if (!user) {
            throw new CustomError('Utilisateur non trouvé', 404);
        }

        if (!(await user.matchPassword(oldPassword))) {
            throw new CustomError('Ancien mot de passe incorrect', 401);
        }

        const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
        user.changePasswordCode = resetCode;
        user.changePasswordExpires = Date.now() + 15 * 60 * 1000;

        await userRepository.save(user);

        const message = `Bonjour ${user.firstName},\n\nVous avez demandé à changer votre mot de passe depuis l'application.\nVoici votre code de sécurité : ${resetCode}\nValable pendant 15 minutes.`;

        if (!process.env.SMTP_USER || process.env.SMTP_USER === '') {
            console.log(`[DEV ONLY] Simulation d'email de changement MdP pour ${user.email} - CODE: ${resetCode}`);
            return { message: 'Code envoyé (simulé).' };
        }

        try {
            await sendEmail({ email: user.email, subject: 'Changement de votre mot de passe', message });
            return { message: 'Code envoyé par email.' };
        } catch (error) {
            user.changePasswordCode = undefined;
            user.changePasswordExpires = undefined;
            await userRepository.save(user);
            throw new CustomError("Erreur lors de l'envoi de l'email.", 500);
        }
    }

    async verifyPasswordChange(userId, code, newPassword) {
        const user = await userRepository.findById(userId);
        if (!user) {
            throw new CustomError('Utilisateur non trouvé', 404);
        }

        if (user.changePasswordCode !== code || user.changePasswordExpires < Date.now()) {
            throw new CustomError('Code invalide ou expiré', 400);
        }

        user.password = newPassword;
        user.changePasswordCode = undefined;
        user.changePasswordExpires = undefined;
        user.sessionsValidAfter = new Date(); 

        await userRepository.save(user);
        return { message: 'Mot de passe mis à jour et déconnecté des autres appareils.' };
    }
}

module.exports = new UserService();
