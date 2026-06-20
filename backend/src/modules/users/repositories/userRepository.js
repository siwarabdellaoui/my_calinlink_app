const User = require('../models/User');

class UserRepository {
    async findById(id) {
        return await User.findById(id);
    }

    async findByEmail(email) {
        return await User.findOne({ email });
    }

    async create(userData) {
        return await User.create(userData);
    }

    async updateById(id, updateData) {
        return await User.findByIdAndUpdate(id, updateData, { new: true });
    }

    async addDevice(userId, deviceId) {
        return await User.findByIdAndUpdate(userId, { $push: { devices: deviceId } });
    }

    async save(user) {
        return await user.save();
    }
}

module.exports = new UserRepository();
