const express = require('express');
const { registerUser, loginUser, getUserProfile, saveFcmToken  } = require('../controllers/user.controller.js');
const { protect } = require('../middleware/auth.middleware.js');
const router = express.Router();

router.post('/', registerUser);
router.post('/login', loginUser);
router.get('/profile', protect, getUserProfile);
router.post('/fcm-token', protect, saveFcmToken);
module.exports = router;