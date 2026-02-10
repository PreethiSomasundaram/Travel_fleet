const express = require('express');
const Bill = require('../models/Bill');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

// ── GET /api/bills ──────────────────────────────────────────────────────────
router.get('/', auth, async (req, res) => {
  try {
    const filter = {};
    if (req.query.tripId) filter.tripId = req.query.tripId;
    if (req.query.driverId) filter.driverId = req.query.driverId;
    if (req.query.status) filter.status = req.query.status;
    const bills = await Bill.find(filter).sort({ createdAt: -1 });
    res.json(bills);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── GET /api/bills/:id ─────────────────────────────────────────────────────
router.get('/:id', auth, async (req, res) => {
  try {
    const bill = await Bill.findById(req.params.id);
    if (!bill) return res.status(404).json({ error: 'Bill not found' });
    res.json(bill);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/bills/:id ─────────────────────────────────────────────────────
router.put('/:id', auth, requireRole('owner', 'employee'), async (req, res) => {
  try {
    const bill = await Bill.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!bill) return res.status(404).json({ error: 'Bill not found' });
    res.json(bill);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── DELETE /api/bills/:id ───────────────────────────────────────────────────
router.delete('/:id', auth, requireRole('owner'), async (req, res) => {
  try {
    await Bill.findByIdAndDelete(req.params.id);
    res.json({ message: 'Bill deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
