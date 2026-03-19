const { body } = require('express-validator');
const Trip = require('../models/Trip');
const Vehicle = require('../models/Vehicle');
const Driver = require('../models/Driver');
const VehicleBataRate = require('../models/VehicleBataRate');

const tripValidation = [
  body('pickupDateTime').isISO8601(),
  body('customerName').notEmpty(),
  body('customerMobile').isLength({ min: 8 }),
  body('pickupLocation').notEmpty(),
  body('placesToVisit').isArray({ min: 1 }),
  body('numberOfDays').isInt({ min: 1 }),
  body('driverId').isMongoId(),
  body('vehicleId').isMongoId(),
];

const assignBataValidation = [body('amount').isFloat({ min: 0 })];

const createTrip = async (req, res) => {
  const payload = req.body;

  const [driver, vehicle] = await Promise.all([
    Driver.findById(payload.driverId),
    Vehicle.findById(payload.vehicleId),
  ]);

  if (!driver || !vehicle) {
    res.status(400);
    throw new Error('Invalid driver or vehicle');
  }

  const rate = await VehicleBataRate.findOne({ category: vehicle.category });
  const defaultBata = rate ? Number(rate.amount) : 0;

  const trip = await Trip.create({
    ...payload,
    driverBataAssigned: defaultBata,
    driverBataAssignedBy: req.user._id,
    driverBataAssignedAt: new Date(),
    createdBy: req.user._id,
  });

  res.status(201).json(trip);
};

const getTrips = async (_req, res) => {
  const trips = await Trip.find()
    .populate('driverId', 'name phone')
    .populate('vehicleId', 'number')
    .sort({ createdAt: -1 });
  res.json(trips);
};

const updateTrip = async (req, res) => {
  const trip = await Trip.findById(req.params.id);
  if (!trip) {
    res.status(404);
    throw new Error('Trip not found');
  }

  Object.assign(trip, req.body);
  await trip.save();
  res.json(trip);
};

const startTrip = async (req, res) => {
  const { startKm } = req.body;
  const trip = await Trip.findById(req.params.id);
  if (!trip) {
    res.status(404);
    throw new Error('Trip not found');
  }

  trip.startKm = startKm;
  trip.startTime = new Date();
  trip.status = 'in_progress';
  await trip.save();

  res.json(trip);
};

const endTrip = async (req, res) => {
  const { endKm, tollApplicable, permitApplicable, parkingApplicable } = req.body;
  const trip = await Trip.findById(req.params.id);

  if (!trip) {
    res.status(404);
    throw new Error('Trip not found');
  }

  trip.endKm = endKm;
  trip.endTime = new Date();
  trip.tollApplicable = Boolean(tollApplicable);
  trip.permitApplicable = Boolean(permitApplicable);
  trip.parkingApplicable = Boolean(parkingApplicable);
  trip.status = 'completed';

  await trip.save();

  const vehicle = await Vehicle.findById(trip.vehicleId);
  if (vehicle && endKm > vehicle.currentKm) {
    vehicle.currentKm = endKm;
    await vehicle.save();
  }

  const driver = await Driver.findById(trip.driverId);
  if (driver && trip.startTime && trip.endTime) {
    const hours = (new Date(trip.endTime) - new Date(trip.startTime)) / (1000 * 60 * 60);
    driver.totalWorkingHours += Math.max(hours, 0);
    driver.totalWorkingDays += 1;
    driver.totalTripsCompleted += 1;

    if (trip.driverBataAssigned > 0 && !trip.driverBataCredited) {
      driver.totalBataEarned += trip.driverBataAssigned;
      trip.driverBataCredited = true;
      await trip.save();
    }

    await driver.save();
  }

  res.json(trip);
};

const addAdvance = async (req, res) => {
  const { amount } = req.body;
  const trip = await Trip.findById(req.params.id);

  if (!trip) {
    res.status(404);
    throw new Error('Trip not found');
  }

  trip.advances.push({
    amount,
    addedByRole: req.user.role,
    addedBy: req.user._id,
  });

  await trip.save();
  res.json(trip);
};

const assignDriverBata = async (req, res) => {
  const { amount } = req.body;
  const trip = await Trip.findById(req.params.id);

  if (!trip) {
    res.status(404);
    throw new Error('Trip not found');
  }

  if (trip.status === 'completed') {
    res.status(400);
    throw new Error('Cannot assign bata after trip completion');
  }

  trip.driverBataAssigned = Number(amount);
  trip.driverBataAssignedBy = req.user._id;
  trip.driverBataAssignedAt = new Date();

  await trip.save();
  res.json(trip);
};

module.exports = {
  tripValidation,
  assignBataValidation,
  createTrip,
  getTrips,
  updateTrip,
  startTrip,
  endTrip,
  addAdvance,
  assignDriverBata,
};
