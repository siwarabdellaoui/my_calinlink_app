const express = require('express');
const router = express.Router();
const { getUserProfile, updateUserProfile, logoutAllDevices, requestPasswordChange, verifyPasswordChange } = require('../controllers/userController');
const { protect } = require('../middleware/authMiddleware');

router.route('/profile')
    .get(protect, getUserProfile)
    .put(protect, updateUserProfile);

router.post('/logout-all', protect, logoutAllDevices);
router.post('/change-password-request', protect, requestPasswordChange);
router.post('/change-password-verify', protect, verifyPasswordChange);

module.exports = router;
