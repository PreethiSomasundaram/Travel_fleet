const express = require('express');
const Advance = require('../models/Advance');
const { auth } = require('../middleware/auth');

const router = express.Router();

// ── GET /api/advances?tripId=xxx ────────────────────────────────────────────
router.get('/', auth, async (req, res) => {
  try {
    const filter = {};
    if (req.query.tripId) filter.tripId = req.query.tripId;
    const advances = await Advance.find(filter).sort({ date: -1 });
    res.json(advances);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST /api/advances ──────────────────────────────────────────────────────
router.post('/', auth, async (req, res) => {
  try {
    const advance = await Advance.create(req.body);
    res.status(201).json(advance);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── DELETE /api/advances/:id ────────────────────────────────────────────────
router.delete('/:id', auth, async (req, res) => {
  try {
    await Advance.findByIdAndDelete(req.params.id);
    res.json({ message: 'Advance deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
