const express = require('express');
const router = express.Router();
// This line is the fix. We are now importing all the required functions.
const { 
  getMembers, 
  createMember, 
  deleteMember, 
  renewMembership, 
  getActiveMembers, 
  getExpiredMembers 
} = require('../controllers/member.controller.js');
const { protect } = require('../middleware/auth.middleware.js');

// Add this new route BEFORE the '/:id' route
router.route('/active').get(protect, getActiveMembers);
router.route('/expired').get(protect, getExpiredMembers);

// Routes for getting all members and creating a new one
router.route('/').get(protect, getMembers).post(protect, createMember);

// Routes for deleting and renewing a specific member by their ID
router.route('/:id').delete(protect, deleteMember);
router.route('/:id/renew').put(protect, renewMembership);

module.exports = router;