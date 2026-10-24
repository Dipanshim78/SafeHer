const mongoose = require("mongoose");
const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const sgMail = require("@sendgrid/mail");

sgMail.setApiKey(process.env.SENDGRID_API_KEY);

const passwordResetOtps = new Map();

const normalizeEmail = (email) =>
  typeof email === "string" ? email.trim().toLowerCase() : "";

const generateOtp = () => String(Math.floor(100000 + Math.random() * 900000));

exports.register = async (req, res) => {//this function runs when a user signup
  const { name, email, password, phone } = req.body || {};
  const normalizedName = typeof name === "string" ? name.trim() : "";
  const normalizedEmail = typeof email === "string" ? email.trim().toLowerCase() : "";
  const normalizedPhone = typeof phone === "string" ? phone.trim() : "";

  try {
    if (!normalizedName || !normalizedEmail || !password || !normalizedPhone) {
      return res.status(400).json({ msg: "All fields are required" });
    }
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)) {
      return res.status(400).json({ msg: "Enter a valid email address" });
    }
    if (typeof password !== "string" || password.length < 8) {
      return res.status(400).json({ msg: "Password must be at least 8 characters" });
    }
    if (!/^\+[1-9]\d{6,14}$/.test(normalizedPhone)) {
      return res.status(400).json({ msg: "Phone number must include its country code" });
    }

    const existingUser = await User.findOne({ email: normalizedEmail });
    if (existingUser) {
      return res.status(400).json({ msg: "Email already registered" });
    }

    const hashed = await bcrypt.hash(password, 10);

    const user = new User({
      name: normalizedName,
      email: normalizedEmail,
      password: hashed,
      phone: normalizedPhone,
    });

    await user.save();

    res.status(201).json({ msg: "User registered" });
  }
  catch (err) {
    console.error("Registration failed:", err.message);
    if (err.code === 11000) {
      return res.status(400).json({ msg: "Email already registered" });
    }
    res.status(500).json({ msg: "Error registering user" });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body || {};
  const normalizedEmail = typeof email === "string" ? email.trim().toLowerCase() : "";

  try {
    if (!normalizedEmail || typeof password !== "string" || !password) {
      return res.status(400).json({ msg: "Email and password are required" });
    }

    if (mongoose.connection.readyState !== 1) {
      return res.status(503).json({ msg: "Database is unavailable. Please try again later." });
    }

    const user = await User.findOne({ email: normalizedEmail });
    if (!user) return res.status(401).json({ msg: "Invalid email or password" });

    let isMatch = false;
    if (typeof user.password === "string") {
      isMatch = await bcrypt.compare(password, user.password).catch(() => false);
    }

    const isLegacyMatch = !isMatch && user.password === password;
    if (!isMatch && !isLegacyMatch) {
      return res.status(401).json({ msg: "Invalid email or password" });
    }

    if (isLegacyMatch) {
      user.password = await bcrypt.hash(password, 10);
      await user.save();
    }

    if (!process.env.JWT_SECRET) {
      console.error("JWT_SECRET is not configured");
      return res.status(503).json({ msg: "Authentication is temporarily unavailable" });
    }

    const token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: "7d" });
    res.json({ token });
  }
  catch (err) {
    console.error("Login failed:", err.message);
    res.status(500).json({ msg: "Error logging in" });
  }
};

exports.forgotPassword = async (req, res) => {
  const { email } = req.body || {};
  const normalizedEmail = normalizeEmail(email);

  try {
    if (!normalizedEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)) {
      return res.status(400).json({ msg: "Enter a valid email address" });
    }

    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    const otp = generateOtp();
    // passwordResetOtps.set(normalizedEmail, {
    //   otp,
    //   expiresAt: Date.now() + 10 * 60 * 1000,
    // });

    // return res.status(200).json({
    //   msg: "OTP sent successfully",
    //   otp,
    // });
    passwordResetOtps.set(normalizedEmail, {
  otp,
  expiresAt: Date.now() + 10 * 60 * 1000,
});

const msg = {
  to: normalizedEmail,
  from: process.env.SENDGRID_FROM_EMAIL,
  subject: "SafeHer Password Reset OTP",
  text: `Your SafeHer password reset OTP is ${otp}. This OTP is valid for 10 minutes.`,
};

await sgMail.send(msg);

return res.status(200).json({
  msg: "OTP sent successfully",
});
  } catch (err) {
    console.error("Forgot password failed:", err.message);
    return res.status(500).json({ msg: "Error sending OTP" });
  }
};

exports.resetPassword = async (req, res) => {
  const { email, otp, newPassword } = req.body || {};
  const normalizedEmail = normalizeEmail(email);

  try {
    if (!normalizedEmail || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(normalizedEmail)) {
      return res.status(400).json({ msg: "Enter a valid email address" });
    }

    if (!otp || typeof newPassword !== "string" || newPassword.length < 8) {
      return res.status(400).json({ msg: "Valid OTP and a new password are required" });
    }

    const resetRequest = passwordResetOtps.get(normalizedEmail);
    if (!resetRequest) {
      return res.status(400).json({ msg: "OTP expired or invalid. Request a new one." });
    }

    if (Date.now() > resetRequest.expiresAt) {
      passwordResetOtps.delete(normalizedEmail);
      return res.status(400).json({ msg: "OTP expired. Please request a new one." });
    }

    if (String(resetRequest.otp) !== String(otp)) {
      return res.status(400).json({ msg: "Invalid OTP provided" });
    }

    const user = await User.findOne({ email: normalizedEmail });
    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();
    passwordResetOtps.delete(normalizedEmail);

    return res.status(200).json({ msg: "Password reset successfully" });
  } catch (err) {
    console.error("Reset password failed:", err.message);
    return res.status(500).json({ msg: "Error resetting password" });
  }
};

exports.me = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    if (!user) return res.status(404).json({ msg: "User not found" });
    res.json(user);
  } catch (err) {
    console.error("Profile lookup failed:", err.message);
    res.status(500).json({ msg: "Error fetching profile" });
  }
};
exports.updateProfile = async (req, res) => {
  try {
    const { name, email, secretWord, homeAddress } = req.body || {};

    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({ msg: "User not found" });
    }

    if (typeof name === "string" && name.trim()) {
      user.name = name.trim();
    }

    if (typeof email === "string" && email.trim()) {
      const normalizedEmail = email.trim().toLowerCase();

      const existingUser = await User.findOne({
        email: normalizedEmail,
        _id: { $ne: user._id },
      });

      if (existingUser) {
        return res.status(400).json({
          msg: "Email already registered",
        });
      }

      user.email = normalizedEmail;
    }

    if (typeof secretWord === "string") {
      user.secretWord = secretWord.trim();
    }

    if (typeof homeAddress === "string") {
      user.homeAddress = homeAddress.trim();
    }

    await user.save();

    res.json({
      msg: "Profile updated successfully",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        secretWord: user.secretWord,
        homeAddress: user.homeAddress,
      },
    });
  } catch (err) {
    console.error("Profile update failed:", err.message);
    res.status(500).json({ msg: "Error updating profile" });
  }
};