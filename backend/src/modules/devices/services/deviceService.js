const deviceRepository = require('../repositories/deviceRepository');
const userRepository = require('../../users/repositories/userRepository');
const CustomError = require('../../../core/errors/customError');

class DeviceService {
    async linkDevice(userId, deviceId, name) {
        const deviceExists = await deviceRepository.findByDeviceId(deviceId);

        if (deviceExists) {
            throw new CustomError('Cet appareil est déjà enregistré.', 400);
        }

        const device = await deviceRepository.create({
            deviceId,
            owner: userId,
            name: name || 'Lit Bébé CâlinLink'
        });

        await userRepository.addDevice(userId, device._id);

        return device;
    }

    async getMyDevices(userId) {
        return await deviceRepository.findDevicesByUserId(userId);
    }

    async updateDeviceStatus(userId, deviceObjId, statusUpdates) {
        const device = await deviceRepository.findById(deviceObjId);

        if (!device) {
            throw new CustomError('Appareil non trouvé', 404);
        }

        const isOwner = device.owner.toString() === userId.toString();
        const isShared = device.sharedWith && device.sharedWith.includes(userId);

        if (!isOwner && !isShared) {
            throw new CustomError('Non autorisé à modifier cet appareil', 401);
        }

        if (statusUpdates.isBerceuseEnabled !== undefined) {
            device.status.isBerceuseEnabled = statusUpdates.isBerceuseEnabled;
        }
        if (statusUpdates.isDouceNuitEnabled !== undefined) {
            device.status.isDouceNuitEnabled = statusUpdates.isDouceNuitEnabled;
        }

        return await deviceRepository.save(device);
    }

    async shareDevice(ownerUserId, invitedEmail) {
        const invitedUser = await userRepository.findByEmail(invitedEmail);
        
        if (!invitedUser) {
            throw new CustomError("Aucun utilisateur trouvé avec cet email.", 404);
        }

        if (invitedUser._id.toString() === ownerUserId.toString()) {
            throw new CustomError("Vous ne pouvez pas partager un appareil avec vous-même.", 400);
        }

        const device = await deviceRepository.findFirstByOwnerId(ownerUserId);
        if (!device) {
            throw new CustomError("Vous n'avez pas de lit à partager.", 404);
        }

        if (device.sharedWith && device.sharedWith.includes(invitedUser._id)) {
            throw new CustomError("Cet utilisateur a déjà accès au lit.", 400);
        }

        device.sharedWith.push(invitedUser._id);
        await deviceRepository.save(device);

        await userRepository.addDevice(invitedUser._id, device._id);

        return { message: "Accès partagé avec succès !" };
    }
}

module.exports = new DeviceService();
