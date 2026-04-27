const mongoose = require('mongoose');

const DeviceSchema = new mongoose.Schema({
    deviceId: {
        type: String,
        required: true, // par exemple "CALINLINK-A1B2C3"
        unique: true
    },
    owner: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    sharedWith: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }],
    name: {
        type: String,
        default: 'Lit Bébé CâlinLink'
    },
    status: {
        isOnline: { type: Boolean, default: false },
        isBerceuseEnabled: { type: Boolean, default: false },
        isDouceNuitEnabled: { type: Boolean, default: false },
        lastSeen: { type: Date, default: Date.now }
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Device', DeviceSchema);
