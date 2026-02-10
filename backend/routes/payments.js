const express = require('express');
const Payment = require('../models/Payment');
const Bill = require('../models/Bill');
const { auth, requireRole } = require('../middleware/auth');

const router = express.Router();

// ── GET /api/payments ───────────────────────────────────────────────────────
router.get('/', auth, async (req, res) => {
  try {
    const filter = {};
    if (req.query.billId) filter.billId = req.query.billId;
    const payments = await Payment.find(filter).sort({ date: -1 });
    res.json(payments);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── POST /api/payments ──────────────────────────────────────────────────────
router.post('/', auth, requireRole('owner', 'employee'), async (req, res) => {
  try {
    const payment = await Payment.create(req.body);

    // ── update bill balance ───────────────────────────────────────────────
    if (payment.billId) {
      const bill = await Bill.findById(payment.billId);
      if (bill) {
        const allPayments = await Payment.find({ billId: bill._id.toString() });
        const totalPaid = allPayments.reduce((s, p) => s + p.amount, 0);
        bill.balanceAmount = bill.totalBill - bill.advanceAmount - totalPaid;
        bill.status = bill.balanceAmount <= 0 ? 'paid' : 'partial';
        await bill.save();
      }
    }

    res.status(201).json(payment);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── DELETE /api/payments/:id ────────────────────────────────────────────────
router.delete('/:id', auth, requireRole('owner'), async (req, res) => {
  try {
    const payment = await Payment.findByIdAndDelete(req.params.id);
    if (payment && payment.billId) {
      const bill = await Bill.findById(payment.billId);
      if (bill) {
        const allPayments = await Payment.find({ billId: bill._id.toString() });
        const totalPaid = allPayments.reduce((s, p) => s + p.amount, 0);
        bill.balanceAmount = bill.totalBill - bill.advanceAmount - totalPaid;
        bill.status = bill.balanceAmount <= 0 ? 'paid' : bill.balanceAmount < bill.totalBill ? 'partial' : 'unpaid';
        await bill.save();
      }
    }
    res.json({ message: 'Payment deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
