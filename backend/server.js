const express = require("express");
const mongoose = require("mongoose");
const dotenv = require("dotenv");
const path = require("path");
const cors = require("cors");

dotenv.config({ path: path.resolve(__dirname, ".env"), override: true });

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// ✅ IMPORT ROUTES
const authRoutes = require("./routes/authRoutes");
const alertRoutes = require("./routes/alertRoutes");
const contactRoutes = require("./routes/contactRoutes");
const chatbotRoutes = require("./routes/chatbotRoutes");
const mapRoutes = require("./routes/mapRoutes");

// ✅ USE ROUTES (VERY IMPORTANT)
app.use("/api/auth", authRoutes);
app.use("/api/alerts", alertRoutes);
app.use("/api/contacts", contactRoutes);
app.use("/api/chatbot", chatbotRoutes);
app.use("/api/map", mapRoutes);

app.get("/", (req, res) => {
  res.send("API running...");
});

app.get("/api/health", (req, res) => {
  const databaseConnected = mongoose.connection.readyState === 1;
  res.status(databaseConnected ? 200 : 503).json({
    status: databaseConnected ? "ok" : "database_unavailable",
  });
});

app.use((req, res) => {
  res.status(404).json({ msg: "Route not found" });
});

app.use((err, req, res, next) => {
  if (res.headersSent) return next(err);

  const status = err.status || 500;
  res.status(status).json({
    msg: status < 500 ? err.message : "Internal server error",
  });
});

if (require.main === module) {
  const mongoUri = process.env.MONGO_URI || "mongodb://127.0.0.1:27017/safeher";
  const port = Number(process.env.PORT || 5000);

  mongoose.connect(mongoUri)
    .then(() => console.log("MongoDB connected"))
    .catch((err) => console.error("MongoDB connection failed:", err.message));

  app.listen(port, () => console.log(`Server running on port ${port}`));
}

module.exports = app;