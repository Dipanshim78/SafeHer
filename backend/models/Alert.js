const mongoose = require("mongoose");

const alertSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  latitude: { type: Number },
  longitude: { type: Number },
}, { timestamps: true });

module.exports = mongoose.model("Alert", alertSchema);