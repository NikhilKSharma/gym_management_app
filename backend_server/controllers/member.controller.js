const Member = require('../models/member.model.js');

// @desc    Get all members for a logged-in user, with optional search
// @route   GET /api/members
// @access  Private
const getMembers = async (req, res) => {
  try {
    const query = { userId: req.user._id };

    if (req.query.search) {
      query.name = { $regex: req.query.search, $options: 'i' };
    }

    const members = await Member.find(query).populate('trainerId', 'name');
    res.status(200).json(members);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Create a new member
// @route   POST /api/members
// @access  Private
const createMember = async (req, res) => {
  const { name, gender, dob, height, weight, trainerId, membershipPlan } = req.body;
  
  if (!name || !gender || !dob || !membershipPlan) {
    return res.status(400).json({ message: 'Please provide all required fields' });
  }

  try {
    const startDate = new Date();
    const endDate = new Date();
    const planMonths = parseInt(membershipPlan.split('-')[0]);
    endDate.setMonth(endDate.getMonth() + planMonths);

    const member = new Member({
      userId: req.user._id,
      name,
      gender,
      dob,
      height,
      weight,
      photoUrl: null,
      trainerId,
      membershipStartDate: startDate,
      membershipEndDate: endDate,
    });

    const createdMember = await member.save();
    res.status(201).json(createdMember);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Delete a member
// @route   DELETE /api/members/:id
// @access  Private
const deleteMember = async (req, res) => {
  try {
    const member = await Member.findById(req.params.id);

    if (!member) {
      return res.status(404).json({ message: 'Member not found' });
    }

    if (member.userId.toString() !== req.user._id.toString()) {
      return res.status(401).json({ message: 'User not authorized' });
    }
    
    await member.deleteOne();
    
    res.status(200).json({ message: 'Member removed' });
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Renew a member's membership
// @route   PUT /api/members/:id/renew
// @access  Private
const renewMembership = async (req, res) => {
    const { membershipPlan } = req.body;
    
    if (!membershipPlan) {
      return res.status(400).json({ message: 'Membership plan is required' });
    }
    
    try {
        const member = await Member.findById(req.params.id);

        if (!member) {
            return res.status(404).json({ message: 'Member not found' });
        }

        if (member.userId.toString() !== req.user._id.toString()) {
            return res.status(401).json({ message: 'User not authorized' });
        }
        
        const planMonths = parseInt(membershipPlan.split('-')[0]);
        
        const renewalStartDate = new Date() > member.membershipEndDate ? new Date() : member.membershipEndDate;
        const newEndDate = new Date(renewalStartDate);
        newEndDate.setMonth(newEndDate.getMonth() + planMonths);
        
        member.membershipEndDate = newEndDate;
        
        if (new Date() > member.membershipEndDate) {
            member.membershipStartDate = new Date();
        }
        
        const updatedMember = await member.save();
        res.status(200).json(updatedMember);
        
    } catch(error) {
        res.status(500).json({ message: 'Server Error' });
    }
};

// @desc    Get currently active members for a user
// @route   GET /api/members/active
// @access  Private
const getActiveMembers = async (req, res) => {
  try {
    const members = await Member.find({ 
      userId: req.user._id,
      membershipEndDate: { $gte: new Date() }
    }).populate('trainerId', 'name');
    
    res.status(200).json(members);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

// @desc    Get expired members for a user
// @route   GET /api/members/expired
// @access  Private
const getExpiredMembers = async (req, res) => {
  try {
    const members = await Member.find({
      userId: req.user._id,
      membershipEndDate: { $lt: new Date() }
    }).populate('trainerId', 'name');
    
    res.status(200).json(members);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = { 
  getMembers, 
  createMember, 
  deleteMember, 
  renewMembership, 
  getActiveMembers,
  getExpiredMembers 
};