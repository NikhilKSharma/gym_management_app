const Trainer = require('../models/trainer.model.js');
const Member = require('../models/member.model.js'); // Make sure to require the Member model
// @desc    Create a new trainer
// @route   POST /api/trainers
// @access  Private
const createTrainer = async (req, res) => {
  const { name, gender } = req.body;

  if (!name || !gender) {
    return res.status(400).json({ message: 'Please add all fields' });
  }

  try {
    const trainer = await Trainer.create({
      name,
      gender,
      userId: req.user._id, // Associate with logged-in user
    });
    res.status(201).json(trainer);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Get all trainers for a user
// @route   GET /api/trainers
// @access  Private
const getAllTrainers = async (req, res) => {
  try {
    // Only find trainers that match the logged-in user's ID
    const trainers = await Trainer.find({ userId: req.user._id });
    res.status(200).json(trainers);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};
const getMembersByTrainer = async (req, res) => {
  try {
    // Find members that belong to the logged-in user AND are assigned to the specific trainer
    const members = await Member.find({ 
      userId: req.user._id, 
      trainerId: req.params.id 
    });
    res.status(200).json(members);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};


module.exports = {
  createTrainer,
  getAllTrainers,
  getMembersByTrainer, // Add this
};