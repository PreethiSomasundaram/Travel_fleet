const mongoose = require('mongoose');

const carSchema = new mongoose.Schema({
  vehicleNumber:       { type: String, required: true, unique: true },
  vehicleType:         { type: String, required: true },
  currentKm:           { type: Number, required: true, default: 0 },
  nextServiceKm:       { type: Number, required: true, default: 0 },
  fcExpiryDate:        { type: String, required: true },
  insuranceExpiryDate: { type: String, required: true },
  pucExpiryDate:       { type: String, required: true },
}, { timestamps: true });

carSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Car', carSchema);
