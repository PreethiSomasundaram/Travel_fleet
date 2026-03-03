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
  try {    const { startingKm, startTime } = req.body;
    const trip = await Trip.findByIdAndUpdate(
      req.params.id,
      { startingKm, startTime, status: 'started' },
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
  try {    const { endingKm, toll, permit, parking, otherCharges } = req.body;
    const trip = await Trip.findById(req.params.id);
    if (!trip) return res.status(404).json({ error: 'Trip not found' });

    trip.endingKm = endingKm;
    trip.endTime = new Date().toISOString();
    trip.toll = toll || 0;
    trip.permit = permit || 0;
    trip.parking = parking || 0;
    trip.otherCharges = otherCharges || 0;
    trip.status = 'ended';
    await trip.save();

    // ── auto-generate bill ────────────────────────────────────────────────
    const totalKm = (trip.endingKm || 0) - (trip.startingKm || 0);
    const totalDays = _calcDays(trip.startTime, trip.endTime);
    const bataConf = await BataConfig.findOne({ vehicleType: 'sedan' });
    const bataPerDay = bataConf ? bataConf.bataPerDay : 500;
    const driverBata = totalDays * bataPerDay;
    const chargesTotal = (trip.toll || 0) + (trip.permit || 0) + (trip.parking || 0) + (trip.otherCharges || 0);
    const totalAmount = driverBata + chargesTotal;

    await Bill.create({
      tripId: trip._id.toString(),
      billDate: new Date().toISOString(),
      tripDate: trip.pickupDate || new Date().toISOString(),
      vehicleNumber: 'N/A',
      placesToVisit: trip.placesToVisit,
      startDateTime: trip.startTime || '',
      endDateTime: trip.endTime || '',
      startingKm: trip.startingKm || 0,
      endingKm: trip.endingKm || 0,
      totalKm,
      rentType: 'day',
      rentUnits: totalDays,
      ratePerUnit: 0,
      ratePerKm: 0,
      kmAmount: 0,
      driverBata,
      toll: trip.toll || 0,
      permit: trip.permit || 0,
      parking: trip.parking || 0,
      otherCharges: trip.otherCharges || 0,
      totalAmount,
      advanceAmount: 0,
      payableAmount: totalAmount,
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
