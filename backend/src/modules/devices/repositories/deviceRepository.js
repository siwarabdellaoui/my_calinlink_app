const Device = require('../models/Device');

class DeviceRepository {
    async findByDeviceId(deviceId) {
        return await Device.findOne({ deviceId });
    }

    async findById(id) {
        return await Device.findById(id);
    }

    async findFirstByOwnerId(ownerId) {
        return await Device.findOne({ owner: ownerId });
    }

    async findDevicesByUserId(userId) {
        return await Device.find({ 
            $or: [
                { owner: userId },
                { sharedWith: userId }
            ]
        });
    }

    async create(deviceData) {
        return await Device.create(deviceData);
    }

    async save(deviceDocument) {
        return await deviceDocument.save();
    }
}

module.exports = new DeviceRepository();
