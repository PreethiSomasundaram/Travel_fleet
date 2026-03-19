const express = require('express');
const { billValidation, createBill, getBills, getBillPdf } = require('../controllers/billingController');
const { protect, authorizeRoles } = require('../middleware/authMiddleware');
const { validate } = require('../middleware/validationMiddleware');

const router = express.Router();

router.post('/bill', protect, authorizeRoles('owner', 'employee'), billValidation, validate, createBill);
router.get('/bills', protect, getBills);
router.get('/bill/:id/pdf', protect, getBillPdf);

module.exports = router;
