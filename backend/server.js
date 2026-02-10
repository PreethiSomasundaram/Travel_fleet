require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const User = require('./models/User');
const BataConfig = require('./models/BataConfig');

// ── Route imports ───────────────────────────────────────────────────────────
const authRoutes = require('./routes/auth');
const carRoutes = require('./routes/cars');
const tripRoutes = require('./routes/trips');
const advanceRoutes = require('./routes/advances');
const billRoutes = require('./routes/bills');
const paymentRoutes = require('./routes/payments');
const leaveRoutes = require('./routes/leaves');
const bataConfigRoutes = require('./routes/bataConfig');

const app = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ───────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ── API Routes ──────────────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/cars', carRoutes);
app.use('/api/trips', tripRoutes);
app.use('/api/advances', advanceRoutes);
app.use('/api/bills', billRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/leaves', leaveRoutes);
app.use('/api/bata-config', bataConfigRoutes);

// ── Health check ────────────────────────────────────────────────────────────
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

// ── Seed defaults ───────────────────────────────────────────────────────────
async function seedDefaults() {
  // Create default owner account if no users exist
  const userCount = await User.countDocuments();
  if (userCount === 0) {
    await User.create({
      name: 'Admin Owner',
      phone: '9999999999',
      role: 'owner',
      username: 'owner',
      password: 'owner123',
    });
    console.log('✅ Default owner account created (owner / owner123)');
  }

  // Seed bata config if empty
  const bataCount = await BataConfig.countDocuments();
  if (bataCount === 0) {
    const defaults = [
      { vehicleType: 'sedan', bataPerDay: 500 },
      { vehicleType: 'suv', bataPerDay: 600 },
      { vehicleType: 'innova', bataPerDay: 700 },
      { vehicleType: 'tempo', bataPerDay: 800 },
      { vehicleType: 'bus', bataPerDay: 1000 },
      { vehicleType: 'mini_bus', bataPerDay: 900 },
    ];
    await BataConfig.insertMany(defaults);
    console.log('✅ Default bata config seeded');
  }
}

// ── Start ───────────────────────────────────────────────────────────────────
mongoose
  .connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('🟢 Connected to MongoDB Atlas');
    await seedDefaults();
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  })
  .catch((err) => {
    console.error('🔴 MongoDB connection error:', err.message);
    process.exit(1);
  });
