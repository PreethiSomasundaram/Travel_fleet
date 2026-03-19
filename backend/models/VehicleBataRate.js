const mongoose = require('mongoose');

const vehicleBataRateSchema = new mongoose.Schema(
  {
    category: {
      type: String,
      required: true,
      unique: true,
      enum: ['sedan', 'suv', 'mvp', 'van', 'hatchback', 'luxury', 'mini_bus', 'other'],
    },
    amount: { type: Number, required: true, min: 0, default: 0 },
    updatedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('VehicleBataRate', vehicleBataRateSchema);
