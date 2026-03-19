const mongoose = require('mongoose');

const billSchema = new mongoose.Schema(
  {
    tripId: { type: mongoose.Schema.Types.ObjectId, ref: 'Trip', required: true },
    billDate: { type: Date, required: true },
    tripDate: { type: Date, required: true },
    vehicleNumber: { type: String, required: true },
    tripDetails: { type: String, required: true },
    startTime: { type: Date },
    endTime: { type: Date },
    startKm: { type: Number, required: true },
    endKm: { type: Number, required: true },
    ratePerKm: { type: Number, required: true, min: 0 },
    dayRent: { type: Number, default: 0 },
    hourRent: { type: Number, default: 0 },
    numberOfDays: { type: Number, default: 0 },
    numberOfHours: { type: Number, default: 0 },
    driverBata: { type: Number, default: 0 },
    tollCharges: { type: Number, default: 0 },
    permitCharges: { type: Number, default: 0 },
    parkingCharges: { type: Number, default: 0 },
    advanceReceived: { type: Number, default: 0 },
    totalKm: { type: Number, required: true },
    kmCharge: { type: Number, required: true },
    totalAmount: { type: Number, required: true },
    payableAmount: { type: Number, required: true },
    pdfPath: { type: String },
    paymentStatus: { type: String, enum: ['paid', 'pending'], default: 'pending' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Bill', billSchema);
