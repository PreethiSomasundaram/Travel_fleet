const express = require('express');
const BataConfig = require('../models/BataConfig');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

// ── GET /api/bata-config ────────────────────────────────────────────────────
router.get('/', auth, async (req, res) => {
  try {
    const configs = await BataConfig.find();
    res.json(configs);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/bata-config/:vehicleType ───────────────────────────────────────
router.put('/:vehicleType', auth, requireRole('owner'), async (req, res) => {
  try {
    const config = await BataConfig.findOneAndUpdate(
      { vehicleType: req.params.vehicleType },
      { bataPerDay: req.body.bataPerDay },
      { new: true, upsert: true, runValidators: true }
    );
    res.json(config);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
