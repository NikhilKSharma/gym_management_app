const mongoose = require('mongoose');

const memberSchema = mongoose.Schema(
  {
    userId: { // The gym owner who created this member
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'User',
    },
    name: { type: String, required: true },
    gender: { type: String, required: true },
    dob: { type: Date, required: true }, // Date of Birth
    height: { type: Number },
    weight: { type: Number },
    photoUrl: { type: String },
    trainerId: { // Optional assigned trainer
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Trainer',
      default: null,
    },
    membershipStartDate: { type: Date, required: true },
    membershipEndDate: { type: Date, required: true },
  },
  {
    timestamps: true,
  }
);

const Member = mongoose.model('Member', memberSchema);
module.exports = Member;