const dataRepository = require('../repositories/dataRepository');
const alertRepository = require('../../alerts/repositories/alertRepository');
const deviceRepository = require('../../devices/repositories/deviceRepository');
const CustomError = require('../../../core/errors/customError');

class DataService {
    async getSensorData(userId, deviceId) {
        const device = await deviceRepository.findById(deviceId);
        
        if (!device || device.owner.toString() !== userId.toString()) {
            throw new CustomError('Non autorisé à voir ces données', 401);
        }

        return await dataRepository.findRecentByDeviceId(deviceId);
    }

    async getAlerts(userId) {
        return await alertRepository.findByUserId(userId);
    }

    async markAlertAsRead(userId, alertId) {
        const alert = await alertRepository.findById(alertId);

        if (!alert || alert.user.toString() !== userId.toString()) {
            throw new CustomError('Alerte non trouvée', 404);
        }

        alert.isRead = true;
        return await alertRepository.save(alert);
    }

    async mockSensorData(deviceId, data) {
        return await dataRepository.create({
            device: deviceId,
            temperature: data.temperature || (20 + Math.random() * 2),
            humidity: data.humidity || (50 + Math.random() * 10),
            motionDetected: data.motionDetected || false
        });
    }
}

module.exports = new DataService();
