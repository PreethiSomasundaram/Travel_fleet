const { body } = require('express-validator');
const Driver = require('../models/Driver');
const User = require('../models/User');

const driverValidation = [
  body('name').notEmpty(),
  body('phone').notEmpty(),
  body('licenseNumber').notEmpty(),
  body('email').optional().isEmail(),
  body('password').optional().isLength({ min: 6 }),
];

const createDriver = async (req, res) => {
  const payload = { ...req.body };
  let user = null;

  if (payload.email || payload.password) {
    if (!payload.email || !payload.password) {
      res.status(400);
      throw new Error('Both email and password are required to create driver login');
    }

    const existingUser = await User.findOne({ email: payload.email });
    if (existingUser) {
      res.status(400);
      throw new Error('Driver login email already exists');
    }

    user = await User.create({
      name: payload.name,
      email: payload.email,
      password: payload.password,
      role: 'driver',
    });
  }

  delete payload.email;
  delete payload.password;

  if (user) {
    payload.userId = user._id;
  }

  const driver = await Driver.create(payload);
  res.status(201).json(driver);
};

const getDrivers = async (_req, res) => {
  const drivers = await Driver.find().populate('userId', 'name email role').sort({ createdAt: -1 });
  res.json(drivers);
};

const applyLeave = async (req, res) => {
  const { from, to, reason } = req.body;
  const driver = await Driver.findById(req.params.id);

  if (!driver) {
    res.status(404);
    throw new Error('Driver not found');
  }

  if (req.user.role === 'driver' && String(driver.userId) !== String(req.user._id)) {
    res.status(403);
    throw new Error('Drivers can apply leave only for their own profile');
  }

  driver.leaves.push({ from, to, reason });
  await driver.save();
  res.json(driver);
};

const approveLeave = async (req, res) => {
  const { leaveId, status } = req.body;
  const driver = await Driver.findById(req.params.id);

  if (!driver) {
    res.status(404);
    throw new Error('Driver not found');
  }

  const leave = driver.leaves.id(leaveId);
  if (!leave) {
    res.status(404);
    throw new Error('Leave request not found');
  }

  leave.status = status;
  leave.approvedBy = req.user._id;
  await driver.save();

  res.json(driver);
};

const getPayrollSummary = async (req, res) => {
  const driver = await Driver.findById(req.params.id);
  if (!driver) {
    res.status(404);
    throw new Error('Driver not found');
  }

  if (req.user.role === 'driver' && String(driver.userId) !== String(req.user._id)) {
    res.status(403);
    throw new Error('Drivers can view payroll only for their own profile');
  }

  const salaryFromDays = driver.totalWorkingDays * (driver.salaryPerDay || 0);
  const salaryFromHours = driver.totalWorkingHours * ((driver.salaryPerDay || 0) / 8);
  const tripSalary = driver.totalTripsCompleted * (driver.salaryPerTrip || 0);
  const baseSalary = Math.max(salaryFromDays, salaryFromHours);
  const totalBata = driver.totalBataEarned || 0;
  const grossPayable = baseSalary + tripSalary + totalBata;
  const approvedLeaveCount = driver.leaves.filter((l) => l.status === 'approved').length;
  const pendingLeaveCount = driver.leaves.filter((l) => l.status === 'pending').length;

  res.json({
    driverId: driver._id,
    driverName: driver.name,
    totalWorkingDays: driver.totalWorkingDays,
    totalWorkingHours: driver.totalWorkingHours,
    totalTripsCompleted: driver.totalTripsCompleted,
    salaryFromDays,
    salaryFromHours,
    tripSalary,
    totalBata,
    approvedLeaveCount,
    pendingLeaveCount,
    estimatedSalary: baseSalary,
    grossPayable,
  });
};

module.exports = {
  driverValidation,
  createDriver,
  getDrivers,
  applyLeave,
  approveLeave,
  getPayrollSummary,
};
