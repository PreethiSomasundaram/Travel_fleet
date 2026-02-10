const express = require('express');
const Trip = require('../models/Trip');
const Bill = require('../models/Bill');
const BataConfig = require('../models/BataConfig');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

// ── GET /api/trips ──────────────────────────────────────────────────────────
router.get('/', auth, async (req, res) => {
  try {
    const filter = {};
    if (req.query.driverId) filter.driverId = req.query.driverId;
    if (req.query.carId) filter.carId = req.query.carId;
    if (req.query.status) filter.status = req.query.status;
    const trips = await Trip.find(filter).sort({ createdAt: -1 });
    res.json(trips);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── GET /api/trips/:id ─────────────────────────────────────────────────────
router.get('/:id', auth, async (req, res) => {
  try {
    const trip = await Trip.findById(req.params.id);
    if (!trip) return res.status(404).json({ error: 'Trip not found' });
    res.json(trip);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST /api/trips ─────────────────────────────────────────────────────────
router.post('/', auth, requireRole('owner', 'employee'), async (req, res) => {
  try {
    const trip = await Trip.create(req.body);
    res.status(201).json(trip);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/trips/:id ─────────────────────────────────────────────────────
router.put('/:id', auth, async (req, res) => {
  try {
    const trip = await Trip.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!trip) return res.status(404).json({ error: 'Trip not found' });
    res.json(trip);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/trips/:id/start ────────────────────────────────────────────────
router.put('/:id/start', auth, async (req, res) => {
  try {
    const { startKm, startDate, startTime } = req.body;
    const trip = await Trip.findByIdAndUpdate(
      req.params.id,
      { startKm, startDate, startTime, status: 'ongoing' },
      { new: true, runValidators: true }
    );
    if (!trip) return res.status(404).json({ error: 'Trip not found' });
    res.json(trip);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── PUT /api/trips/:id/end ──────────────────────────────────────────────────
router.put('/:id/end', auth, async (req, res) => {
  try {
    const { endKm, endDate, endTime, tollAmount, permit } = req.body;
    const trip = await Trip.findById(req.params.id);
    if (!trip) return res.status(404).json({ error: 'Trip not found' });

    trip.endKm = endKm;
    trip.endDate = endDate;
    trip.endTime = endTime;
    trip.tollAmount = tollAmount || 0;
    trip.permit = permit || 0;
    trip.totalKm = endKm - trip.startKm;
    trip.status = 'completed';
    await trip.save();

    // ── auto-generate bill ────────────────────────────────────────────────
    const totalDays = _calcDays(trip.startDate, trip.endDate);
    const bataConf = await BataConfig.findOne({ vehicleType: trip.vehicleType || 'sedan' });
    const bataPerDay = bataConf ? bataConf.bataPerDay : 500;
    const driverBata = totalDays * bataPerDay;
    const totalBill = driverBata + trip.tollAmount + trip.permit;

    await Bill.create({
      tripId: trip._id.toString(),
      carId: trip.carId,
      driverId: trip.driverId,
      customerName: trip.customerName,
      startDate: trip.startDate,
      endDate: trip.endDate,
      startKm: trip.startKm,
      endKm: trip.endKm,
      totalKm: trip.totalKm,
      totalDays,
      bataPerDay,
      driverBata,
      tollAmount: trip.tollAmount,
      permit: trip.permit,
      totalBill,
      advanceAmount: 0,
      balanceAmount: totalBill,
      status: 'unpaid',
      generatedBy: req.user.id,
    });

    res.json(trip);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── DELETE /api/trips/:id ───────────────────────────────────────────────────
router.delete('/:id', auth, requireRole('owner'), async (req, res) => {
  try {
    await Trip.findByIdAndDelete(req.params.id);
    res.json({ message: 'Trip deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── helper ──────────────────────────────────────────────────────────────────
function _calcDays(start, end) {
  const s = new Date(start);
  const e = new Date(end);
  const diff = Math.ceil((e - s) / (1000 * 60 * 60 * 24));
  return diff < 1 ? 1 : diff;
}

module.exports = router;
