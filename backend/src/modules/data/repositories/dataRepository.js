const SensorData = require('../models/SensorData');

class DataRepository {
    async findRecentByDeviceId(deviceId, limit = 100) {
        return await SensorData.find({ device: deviceId })
                               .sort({ timestamp: -1 })
                               .limit(limit);
    }

    async create(data) {
        return await SensorData.create(data);
    }
}

module.exports = new DataRepository();
