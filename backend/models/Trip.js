const mongoose = require('mongoose');

const advanceSchema = new mongoose.Schema(
  {
    amount: { type: Number, required: true, min: 0 },
    addedByRole: { type: String, enum: ['owner', 'employee', 'driver'], required: true },
    addedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

const tripSchema = new mongoose.Schema(
  {
    pickupDateTime: { type: Date, required: true },
    customerName: { type: String, required: true, trim: true },
    customerMobile: { type: String, required: true, trim: true },
    pickupLocation: { type: String, required: true },
    placesToVisit: [{ type: String, required: true }],
    numberOfDays: { type: Number, required: true, min: 1 },
    driverId: { type: mongoose.Schema.Types.ObjectId, ref: 'Driver', required: true },
    vehicleId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vehicle', required: true },
    startTime: { type: Date },
    endTime: { type: Date },
    startKm: { type: Number, min: 0 },
    endKm: { type: Number, min: 0 },
    tollApplicable: { type: Boolean, default: false },
    permitApplicable: { type: Boolean, default: false },
    parkingApplicable: { type: Boolean, default: false },
    driverBataAssigned: { type: Number, default: 0, min: 0 },
    driverBataAssignedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    driverBataAssignedAt: { type: Date },
    driverBataCredited: { type: Boolean, default: false },
    status: {
      type: String,
      enum: ['scheduled', 'in_progress', 'completed'],
      default: 'scheduled',
    },
    advances: [advanceSchema],
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Trip', tripSchema);
