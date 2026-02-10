const mongoose = require('mongoose');

const billSchema = new mongoose.Schema({
  tripId:         { type: String, required: true },
  billDate:       { type: String, required: true },
  tripDate:       { type: String, required: true },
  vehicleNumber:  { type: String, required: true },
  placesToVisit:  { type: String, required: true },
  startDateTime:  { type: String, required: true },
  endDateTime:    { type: String, required: true },
  startingKm:     { type: Number, required: true },
  endingKm:       { type: Number, required: true },
  totalKm:        { type: Number, required: true },
  rentType:       { type: String, required: true, enum: ['day', 'hour'] },
  rentUnits:      { type: Number, required: true },
  ratePerUnit:    { type: Number, required: true },
  ratePerKm:      { type: Number, required: true },
  kmAmount:       { type: Number, required: true },
  driverBata:     { type: Number, required: true },
  toll:           { type: Number, default: 0 },
  permit:         { type: Number, default: 0 },
  parking:        { type: Number, default: 0 },
  otherCharges:   { type: Number, default: 0 },
  totalAmount:    { type: Number, required: true },
  advanceAmount:  { type: Number, required: true },
  payableAmount:  { type: Number, required: true },
}, { timestamps: true });

billSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Bill', billSchema);
