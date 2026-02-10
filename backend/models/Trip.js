const mongoose = require('mongoose');

const tripSchema = new mongoose.Schema({
  pickupDate:      { type: String, required: true },
  pickupTime:      { type: String, required: true },
  pickupLocation:  { type: String, required: true },
  numberOfDays:    { type: Number, required: true },
  placesToVisit:   { type: String, required: true },
  carId:           { type: String, default: null },   // Car document id
  driverId:        { type: String, default: null },   // User document id
  status:          { type: String, default: 'created', enum: ['created', 'started', 'ended'] },
  startTime:       { type: String, default: null },
  endTime:         { type: String, default: null },
  startingKm:      { type: Number, default: null },
  endingKm:        { type: Number, default: null },
  toll:            { type: Number, default: 0 },
  permit:          { type: Number, default: 0 },
  parking:         { type: Number, default: 0 },
  otherCharges:    { type: Number, default: 0 },
}, { timestamps: true });

tripSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Trip', tripSchema);
