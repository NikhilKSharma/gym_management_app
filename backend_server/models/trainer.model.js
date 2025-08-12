const mongoose = require('mongoose');

const trainerSchema = mongoose.Schema(
  {
    // Add this block to associate a trainer with a user
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'User',
    },
    name: {
      type: String,
      required: true,
    },
    gender: {
      type: String,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

const Trainer = mongoose.model('Trainer', trainerSchema);
module.exports = Trainer;