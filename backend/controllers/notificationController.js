const Notification = require('../models/Notification');

const getNotifications = async (req, res) => {
  const notifications = await Notification.find({ userId: req.user._id }).sort({ createdAt: -1 });
  res.json(notifications);
};

const markNotificationRead = async (req, res) => {
  const notification = await Notification.findById(req.params.id);
  if (!notification) {
    res.status(404);
    throw new Error('Notification not found');
  }

  if (String(notification.userId) !== String(req.user._id)) {
    res.status(403);
    throw new Error('Forbidden');
  }

  notification.isRead = true;
  await notification.save();

  res.json(notification);
};

module.exports = { getNotifications, markNotificationRead };
