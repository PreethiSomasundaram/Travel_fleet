const express = require('express');
const Leave = require('../models/Leave');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

// ── GET /api/leaves ─────────────────────────────────────────────────────────
router.get('/', auth, async (req, res) => {
  try {
    const filter = {};
    if (req.query.driverId) filter.driverId = req.query.driverId;
    if (req.query.status) filter.status = req.query.status;
    const leaves = await Leave.find(filter).sort({ date: -1 });
    res.json(leaves);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST /api/leaves ────────────────────────────────────────────────────────
router.post('/', auth, async (req, res) => {
  try {
    const leave = await Leave.create(req.body);
    res.status(201).json(leave);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/leaves/:id ─────────────────────────────────────────────────────
router.put('/:id', auth, async (req, res) => {
  try {
    const leave = await Leave.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!leave) return res.status(404).json({ error: 'Leave not found' });
    res.json(leave);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/leaves/:id/approve ─────────────────────────────────────────────
router.put('/:id/approve', auth, requireRole('owner', 'employee'), async (req, res) => {
  try {
    const leave = await Leave.findByIdAndUpdate(
      req.params.id,
      { status: 'approved' },
      { new: true }
    );
    if (!leave) return res.status(404).json({ error: 'Leave not found' });
    res.json(leave);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/leaves/:id/reject ──────────────────────────────────────────────
router.put('/:id/reject', auth, requireRole('owner', 'employee'), async (req, res) => {
  try {
    const leave = await Leave.findByIdAndUpdate(
      req.params.id,
      { status: 'rejected' },
      { new: true }
    );
    if (!leave) return res.status(404).json({ error: 'Leave not found' });
    res.json(leave);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── DELETE /api/leaves/:id ──────────────────────────────────────────────────
router.delete('/:id', auth, requireRole('owner'), async (req, res) => {
  try {
    await Leave.findByIdAndDelete(req.params.id);
    res.json({ message: 'Leave deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
