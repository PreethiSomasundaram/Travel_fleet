const mongoose = require('mongoose');

const advanceSchema = new mongoose.Schema({
  tripId:      { type: String, required: true },
  amount:      { type: Number, required: true },
  advanceType: { type: String, required: true, enum: ['booking', 'fuel'] },
  enteredBy:   { type: String, required: true },
  date:        { type: String, required: true },
}, { timestamps: true });

advanceSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Advance', advanceSchema);
