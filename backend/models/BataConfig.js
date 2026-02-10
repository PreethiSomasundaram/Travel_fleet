const mongoose = require('mongoose');

const bataConfigSchema = new mongoose.Schema({
  vehicleType: { type: String, required: true, unique: true },
  bataPerDay:  { type: Number, required: true },
}, { timestamps: true });

bataConfigSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('BataConfig', bataConfigSchema);
