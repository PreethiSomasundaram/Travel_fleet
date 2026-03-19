const { body } = require('express-validator');
const path = require('path');
const Bill = require('../models/Bill');
const Trip = require('../models/Trip');
const { generateInvoicePdf } = require('../services/pdfService');

const billValidation = [
  body('tripId').isMongoId(),
  body('billDate').isISO8601(),
  body('tripDate').isISO8601(),
  body('vehicleNumber').notEmpty(),
  body('tripDetails').notEmpty(),
  body('startKm').isNumeric(),
  body('endKm').isNumeric(),
  body('ratePerKm').isNumeric(),
];

const computeBillFields = (payload) => {
  const totalKm = Math.max(Number(payload.endKm) - Number(payload.startKm), 0);
  const kmCharge = totalKm * Number(payload.ratePerKm || 0);

  const totalAmount =
    kmCharge +
    Number(payload.dayRent || 0) +
    Number(payload.hourRent || 0) +
    Number(payload.driverBata || 0) +
    Number(payload.tollCharges || 0) +
    Number(payload.permitCharges || 0) +
    Number(payload.parkingCharges || 0);

  const payableAmount = totalAmount - Number(payload.advanceReceived || 0);

  return { totalKm, kmCharge, totalAmount, payableAmount };
};

const createBill = async (req, res) => {
  const payload = req.body;

  const trip = await Trip.findById(payload.tripId);
  if (!trip) {
    res.status(404);
    throw new Error('Trip not found');
  }

  const totals = computeBillFields(payload);

  const bill = await Bill.create({
    ...payload,
    ...totals,
    startTime: payload.startTime || trip.startTime,
    endTime: payload.endTime || trip.endTime,
  });

  const pdf = await generateInvoicePdf(bill);
  bill.pdfPath = pdf.relativePath;
  await bill.save();

  res.status(201).json(bill);
};

const getBills = async (_req, res) => {
  const bills = await Bill.find().populate('tripId').sort({ createdAt: -1 });
  res.json(bills);
};

const getBillPdf = async (req, res) => {
  const bill = await Bill.findById(req.params.id);
  if (!bill || !bill.pdfPath) {
    res.status(404);
    throw new Error('Bill PDF not found');
  }

  res.download(path.join(__dirname, '..', bill.pdfPath));
};

module.exports = {
  billValidation,
  createBill,
  getBills,
  getBillPdf,
};
