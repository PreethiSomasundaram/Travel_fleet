const express = require('express');
const { createPayment, getPayments, updatePayment } = require('../controllers/paymentController');
const { protect, authorizeRoles } = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/payment', protect, authorizeRoles('owner', 'employee'), createPayment);
router.get('/payments', protect, getPayments);
router.put('/payment/:id', protect, authorizeRoles('owner', 'employee'), updatePayment);

module.exports = router;
