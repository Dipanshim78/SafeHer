// // const mongoose = require("mongoose");

// // const contactSchema = new mongoose.Schema({
// //   userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
// //   name: { type: String, required: true },
// //   phone: { type: String, required: true },
// // }, { timestamps: true });

// // contactSchema.index({ userId: 1, phone: 1 }, { unique: true });

// // module.exports = mongoose.model("Contact", contactSchema);
// const mongoose = require("mongoose");

// const contactSchema = new mongoose.Schema({
//   userId: {
//     type: mongoose.Schema.Types.ObjectId,
//     ref: "User",
//     required: true
//   },
//   name: {
//     type: String,
//     required: true
//   },
//   phone: {
//     type: String,
//     required: true
//   },
//   email: {
//     type: String,
//     required: true
//   },
// }, { timestamps: true });

// contactSchema.index({ userId: 1, phone: 1 }, { unique: true });

// module.exports = mongoose.model("Contact", contactSchema);
const mongoose = require("mongoose");

const contactSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },

  name: {
    type: String,
    required: true
  },

  phone: {
    type: String,
    default: ""
  },

  email: {
    type: String,
    default: ""
  },

}, { timestamps: true });

contactSchema.index({ userId: 1, phone: 1 }, { unique: true, sparse: true });

module.exports = mongoose.model("Contact", contactSchema);