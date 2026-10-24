const express = require("express");
const router = express.Router();

// ✅ Register route
router.post("/register", (req, res) => {
  const { name, email, password } = req.body;

  res.json({
    message: "User registered successfully",
    user: { name, email }
  });
});

// ✅ Login route
router.post("/login", (req, res) => {
  const { email, password } = req.body;

  res.json({
    message: "Login successful",
    user: { email }
  });
});

module.exports = router;