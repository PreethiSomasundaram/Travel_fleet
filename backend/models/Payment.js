const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema(
  {
    billId: { type: mongoose.Schema.Types.ObjectId, ref: 'Bill', required: true },
    amount: { type: Number, required: true, min: 0 },
    status: { type: String, enum: ['paid', 'pending'], default: 'pending' },
    paidAt: { type: Date },
    notes: { type: String },
    updatedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Payment', paymentSchema);
