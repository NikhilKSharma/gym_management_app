const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth.middleware.js');
const { createTrainer, getAllTrainers, getMembersByTrainer } = require('../controllers/trainer.controller.js');
router.route('/').post(protect, createTrainer).get(protect, getAllTrainers);
router.route('/:id/members').get(protect, getMembersByTrainer);
module.exports = router;