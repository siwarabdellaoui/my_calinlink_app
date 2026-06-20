const express = require('express');
const router = express.Router();
const { registerUser, authUser, forgotPassword, verifyResetCode, resetPassword } = require('../controllers/authController');

router.post('/register', registerUser);
router.post('/login', authUser);
router.post('/forgot-password', forgotPassword);
router.post('/verify-reset-code', verifyResetCode);
router.post('/reset-password', resetPassword);

module.exports = router;
