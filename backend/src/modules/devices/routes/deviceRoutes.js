const express = require('express');
const router = express.Router();
const { linkDevice, getMyDevices, updateDeviceStatus, shareDevice } = require('../controllers/deviceController');
const { protect } = require('../../../shared/middlewares/authMiddleware');

router.route('/')
    .post(protect, linkDevice)
    .get(protect, getMyDevices);

router.post('/share', protect, shareDevice);

router.route('/:id/status')
    .put(protect, updateDeviceStatus);

module.exports = router;
