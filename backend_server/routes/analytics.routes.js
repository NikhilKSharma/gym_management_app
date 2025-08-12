const express = require('express');
const router = express.Router();
const { getMembershipStats } = require('../controllers/analytics.controller.js');
const { protect } = require('../middleware/auth.middleware.js');

router.get('/memberships', protect, getMembershipStats);

module.exports = router;