const mongoose = require('mongoose');

const leaveSchema = new mongoose.Schema({
  driverId:  { type: String, required: true },
  date:      { type: String, required: true },
  leaveType: { type: String, required: true, enum: ['full_day', 'half_day'] },
  status:    { type: String, default: 'pending', enum: ['pending', 'approved', 'rejected'] },
  reason:    { type: String, default: null },
}, { timestamps: true });

leaveSchema.set('toJSON', {
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

module.exports = mongoose.model('Leave', leaveSchema);
