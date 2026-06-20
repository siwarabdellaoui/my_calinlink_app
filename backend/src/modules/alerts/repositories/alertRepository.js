const Alert = require('../models/Alert');

class AlertRepository {
    async findByUserId(userId) {
        return await Alert.find({ user: userId }).sort({ createdAt: -1 });
    }

    async findById(alertId) {
        return await Alert.findById(alertId);
    }

    async save(alertDocument) {
        return await alertDocument.save();
    }
}

module.exports = new AlertRepository();
