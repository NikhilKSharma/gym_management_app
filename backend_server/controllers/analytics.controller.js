const Member = require('../models/member.model.js');
const { startOfMonth, endOfMonth, subMonths, format } = require('date-fns');

// @desc    Get monthly active member stats
// @route   GET /api/analytics/memberships
// @access  Private
const getMembershipStats = async (req, res) => {
  const stats = [];
  const today = new Date();

  try {
    // Loop through the last 6 months, including the current one
    for (let i = 5; i >= 0; i--) {
      const targetDate = subMonths(today, i);
      const monthStart = startOfMonth(targetDate);
      const monthEnd = endOfMonth(targetDate);

      // An active member is one whose membership started before the end of the month
      // and ends after the start of the month.
      const activeCount = await Member.countDocuments({
        userId: req.user._id,
        membershipStartDate: { $lte: monthEnd },
        membershipEndDate: { $gte: monthStart },
      });

      stats.push({
        // Format month name e.g., "Jan", "Feb"
        month: format(targetDate, 'MMM'),
        count: activeCount,
      });
    }
    res.status(200).json(stats);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = { getMembershipStats };