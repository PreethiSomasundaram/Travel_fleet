const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  billId:  { type: String, required: true },
  amount:  { type: Number, required: true },
  status:  { type: String, default: 'pending', enum: ['paid', 'pending'] },
  date:    { type: String, required: true },
  remarks: { type: String, default: null },
}, { timestamps: true });

paymentSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Payment', paymentSchema);
