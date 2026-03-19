const Payment = require('../models/Payment');
const Bill = require('../models/Bill');

const createPayment = async (req, res) => {
  const { billId, amount, status, notes } = req.body;

  const bill = await Bill.findById(billId);
  if (!bill) {
    res.status(404);
    throw new Error('Bill not found');
  }

  const payment = await Payment.create({
    billId,
    amount,
    status,
    notes,
    paidAt: status === 'paid' ? new Date() : null,
    updatedBy: req.user._id,
  });

  bill.paymentStatus = status || 'pending';
  await bill.save();

  res.status(201).json(payment);
};

const getPayments = async (_req, res) => {
  const payments = await Payment.find().populate('billId').sort({ createdAt: -1 });
  res.json(payments);
};

const updatePayment = async (req, res) => {
  const payment = await Payment.findById(req.params.id);
  if (!payment) {
    res.status(404);
    throw new Error('Payment not found');
  }

  Object.assign(payment, req.body);
  payment.updatedBy = req.user._id;
  if (payment.status === 'paid' && !payment.paidAt) {
    payment.paidAt = new Date();
  }
  await payment.save();

  const bill = await Bill.findById(payment.billId);
  if (bill) {
    bill.paymentStatus = payment.status;
    await bill.save();
  }

  res.json(payment);
};

module.exports = { createPayment, getPayments, updatePayment };
