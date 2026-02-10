const express = require('express');
const Car = require('../models/Car');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

// ── GET /api/cars ───────────────────────────────────────────────────────────
router.get('/', auth, async (req, res) => {
  try {
    const cars = await Car.find();
    res.json(cars);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── GET /api/cars/:id ───────────────────────────────────────────────────────
router.get('/:id', auth, async (req, res) => {
  try {
    const car = await Car.findById(req.params.id);
    if (!car) return res.status(404).json({ error: 'Car not found' });
    res.json(car);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST /api/cars ──────────────────────────────────────────────────────────
router.post('/', auth, requireRole('owner', 'employee'), async (req, res) => {
  try {
    const car = await Car.create(req.body);
    res.status(201).json(car);
  } catch (err) {
    if (err.code === 11000) {
      return res.status(400).json({ error: 'Plate number already exists' });
    }
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/cars/:id ───────────────────────────────────────────────────────
router.put('/:id', auth, requireRole('owner', 'employee'), async (req, res) => {
  try {
    const car = await Car.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!car) return res.status(404).json({ error: 'Car not found' });
    res.json(car);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── DELETE /api/cars/:id ────────────────────────────────────────────────────
router.delete('/:id', auth, requireRole('owner'), async (req, res) => {
  try {
    await Car.findByIdAndDelete(req.params.id);
    res.json({ message: 'Car deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
