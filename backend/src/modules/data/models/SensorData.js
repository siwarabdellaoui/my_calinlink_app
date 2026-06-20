const mongoose = require('mongoose');

const SensorDataSchema = new mongoose.Schema({
    device: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Device',
        required: true
    },
    temperature: {
        type: Number,
        required: true
    },
    humidity: {
        type: Number,
        required: true
    },
    soundLevel: {
        type: Number,
        default: 0
    },
    motionDetected: {
        type: Boolean,
        default: false
    },
    timestamp: {
        type: Date,
        default: Date.now,
        index: true // Index pour optimiser les requêtes chronologiques
    }
});

module.exports = mongoose.model('SensorData', SensorDataSchema);
