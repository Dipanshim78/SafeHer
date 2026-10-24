// 
const Alert = require("../models/Alert");
const Contact = require("../models/Contact");
const twilio = require("twilio");
const sgMail = require("@sendgrid/mail");

sgMail.setApiKey(process.env.SENDGRID_API_KEY);

exports.sendAlert = async (req, res) => {
  const { latitude, longitude } = req.body || {};

  const hasLatitude = latitude !== undefined && latitude !== null;
  const hasLongitude = longitude !== undefined && longitude !== null;

  if (hasLatitude !== hasLongitude) {
    return res.status(400).json({
      msg: "Latitude and longitude must be provided together",
    });
  }

  if (
    hasLatitude &&
    (
      typeof latitude !== "number" ||
      typeof longitude !== "number" ||
      !Number.isFinite(latitude) ||
      !Number.isFinite(longitude) ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180
    )
  ) {
    return res.status(400).json({
      msg: "A valid latitude and longitude are required",
    });
  }

  try {
    const alert = new Alert({
      userId: req.user.id,
      ...(hasLatitude ? { latitude, longitude } : {}),
    });

    await alert.save();

    const contacts = await Contact.find({ userId: req.user.id });

    let notificationsSent = 0;
    let notificationFailures = 0;
    let deliveryStatus = "no_contacts";

    const locationText = hasLatitude
      ? `Location: https://maps.google.com/?q=${latitude},${longitude}`
      : "Live location is unavailable.";

    const messageBody = `SAFEHER EMERGENCY

I AM IN DANGER! Please help me.

${locationText}`;

    // EMAIL ALERT
    const emailContacts = contacts.filter(
      (contact) => contact.email
    );

    if (
      emailContacts.length &&
      process.env.SENDGRID_API_KEY &&
      process.env.SENDGRID_FROM_EMAIL
    ) {
      const emailResults = await Promise.allSettled(
        emailContacts.map((contact) =>
          sgMail.send({
            to: contact.email,
            from: process.env.SENDGRID_FROM_EMAIL,
            subject: "SAFEHER EMERGENCY ALERT",
            text: messageBody,
          })
        )
      );

      const emailSuccess = emailResults.filter(
        (result) => result.status === "fulfilled"
      ).length;

      const emailFailures = emailResults.length - emailSuccess;

      notificationsSent += emailSuccess;
      notificationFailures += emailFailures;

      if (emailSuccess > 0) {
        deliveryStatus = emailFailures > 0 ? "partial" : "sent";
      }

      for (const result of emailResults) {
        if (result.status === "rejected") {
          console.error(
            "Email delivery failed:",
            result.reason?.message || result.reason
          );
        }
      }
    }

    // TWILIO SMS ALERT
    if (
      contacts.length &&
      process.env.TWILIO_SID &&
      process.env.TWILIO_AUTH_TOKEN &&
      process.env.TWILIO_PHONE
    ) {
      const client = twilio(
        process.env.TWILIO_SID,
        process.env.TWILIO_AUTH_TOKEN
      );

      const smsResults = await Promise.allSettled(
        contacts.map((contact) =>
          client.messages.create({
            body: messageBody,
            from: process.env.TWILIO_PHONE,
            to: contact.phone,
          })
        )
      );

      const smsSuccess = smsResults.filter(
        (result) => result.status === "fulfilled"
      ).length;

      const smsFailures = smsResults.length - smsSuccess;

      notificationsSent += smsSuccess;
      notificationFailures += smsFailures;

      if (smsSuccess > 0) {
        deliveryStatus =
          notificationFailures > 0 ? "partial" : "sent";
      }

      for (const result of smsResults) {
        if (result.status === "rejected") {
          console.error(
            "SMS delivery failed:",
            result.reason?.message || result.reason
          );
        }
      }
    }

    if (contacts.length && notificationsSent === 0) {
      deliveryStatus = "not_configured";
    }

    res.json({
      msg: "SOS alert recorded",
      deliveryStatus,
      notificationsSent,
      notificationFailures,
    });
  } catch (err) {
    console.error("SOS alert failed:", err.message);

    res.status(500).json({
      msg: "Error recording SOS alert",
    });
  }
};