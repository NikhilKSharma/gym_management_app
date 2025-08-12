const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');
// In index.js
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.applicationDefault(),
});
// Load environment variables
dotenv.config();

// Connect to database
connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json()); // To accept JSON data in the body

// Test Route
app.get('/', (req, res) => {
  res.send('API is running...');
});

const userRoutes = require('./routes/user.routes.js');
app.use('/api/users', userRoutes);

const trainerRoutes = require('./routes/trainer.routes.js');
app.use('/api/trainers', trainerRoutes);

const memberRoutes = require('./routes/member.routes.js');
app.use('/api/members', memberRoutes);

const analyticsRoutes = require('./routes/analytics.routes.js');
app.use('/api/analytics', analyticsRoutes);

const PORT = process.env.PORT || 5000;
const cron = require('node-cron');
const { subDays, startOfDay, endOfDay } = require('date-fns');
const Member = require('./models/member.model');
const User = require('./models/user.model');

// Schedule a job to run every day at 9:00 AM
cron.schedule('0 9 * * *', async () => {
  console.log('Running daily check for expiring memberships...');

  const sevenDaysFromNow = endOfDay(subDays(new Date(), -7)); // Exactly 7 days from now
  const today = startOfDay(new Date());

  try {
    const expiringMembers = await Member.find({
      membershipEndDate: { $gte: today, $lte: sevenDaysFromNow }
    });

    console.log(`Found ${expiringMembers.length} members expiring within 7 days.`);

    for (const member of expiringMembers) {
      const user = await User.findById(member.userId);
      if (user && user.fcmToken) {
        const message = {
          notification: {
            title: 'Membership Expiring Soon!',
            body: `${member.name}'s membership is expiring on ${member.membershipEndDate.toLocaleDateString()}.`,
          },
          token: user.fcmToken,
        };

        await admin.messaging().send(message);
        console.log(`Notification sent to ${user.name} for member ${member.name}`);
      }
    }
  } catch (error) {
    console.error('Error sending notifications:', error);
  }
});

app.listen(PORT, console.log(`Server running on port ${PORT}`));