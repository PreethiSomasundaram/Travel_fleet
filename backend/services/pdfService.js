const fs = require('fs');
const path = require('path');
const PDFDocument = require('pdfkit');

const currency = (value) => Number(value || 0).toFixed(2);

const generateInvoicePdf = async (bill) => {
  const outputDir = path.join(__dirname, '..', 'uploads', 'invoices');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const fileName = `invoice-${bill._id}.pdf`;
  const filePath = path.join(outputDir, fileName);

  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 36 });
    const stream = fs.createWriteStream(filePath);

    doc.pipe(stream);

    doc.fontSize(22).text('Travel Fleet Invoice', { align: 'center' });
    doc.moveDown(1);

    doc.fontSize(12);
    doc.text(`Invoice ID: ${bill._id}`);
    doc.text(`Bill Date: ${new Date(bill.billDate).toLocaleDateString()}`);
    doc.text(`Trip Date: ${new Date(bill.tripDate).toLocaleDateString()}`);
    doc.text(`Vehicle Number: ${bill.vehicleNumber}`);
    doc.text(`Trip Details: ${bill.tripDetails}`);
    doc.moveDown(1);

    doc.fontSize(14).text('Trip Metrics', { underline: true });
    doc.fontSize(12);
    doc.text(`Start KM: ${bill.startKm}`);
    doc.text(`End KM: ${bill.endKm}`);
    doc.text(`Total KM: ${bill.totalKm}`);
    doc.text(`Rate / KM: ${currency(bill.ratePerKm)}`);
    doc.text(`KM Charge: ${currency(bill.kmCharge)}`);
    doc.moveDown(1);

    doc.fontSize(14).text('Charge Breakdown', { underline: true });
    doc.fontSize(12);
    doc.text(`Day Rent: ${currency(bill.dayRent)}`);
    doc.text(`Hour Rent: ${currency(bill.hourRent)}`);
    doc.text(`Driver Bata: ${currency(bill.driverBata)}`);
    doc.text(`Toll Charges: ${currency(bill.tollCharges)}`);
    doc.text(`Permit Charges: ${currency(bill.permitCharges)}`);
    doc.text(`Parking Charges: ${currency(bill.parkingCharges)}`);
    doc.moveDown(1);

    doc.fontSize(14).text('Totals', { underline: true });
    doc.fontSize(12);
    doc.text(`Total Amount: ${currency(bill.totalAmount)}`);
    doc.text(`Advance Received: ${currency(bill.advanceReceived)}`);
    doc.text(`Payable Amount: ${currency(bill.payableAmount)}`);

    doc.end();

    stream.on('finish', () => {
      resolve({ filePath, relativePath: path.join('uploads', 'invoices', fileName) });
    });
    stream.on('error', reject);
  });
};

module.exports = { generateInvoicePdf };
