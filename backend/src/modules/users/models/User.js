const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
    firstName: {
        type: String,
        required: true
    },
    lastName: {
        type: String,
        required: true
    },
    avatar: {
        type: String,
        default: ''
    },
    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true
    },
    password: {
        type: String,
        required: true,
        minlength: 6
    },
    phone: {
        type: String,
        default: ''
    },
    babyContext: {
        firstName: { type: String, default: '' },
        birthDate: { type: Date },
        gender: { type: String, enum: ['M', 'F'] }
    },
    devices: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Device'
    }],
    resetPasswordCode: {
        type: String
    },
    resetPasswordExpires: {
        type: Date
    },
    sessionsValidAfter: {
        type: Date,
        default: null
    },
    changePasswordCode: {
        type: String
    },
    changePasswordExpires: {
        type: Date
    }
}, {
    timestamps: true
});

// Middleware pour hasher le mot de passe avant la sauvegarde
UserSchema.pre('save', async function(next) {
    if (!this.isModified('password')) {
        next();
    }
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
});

// Méthode pour comparer les mots de passe
UserSchema.methods.matchPassword = async function(enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);
