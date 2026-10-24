const express = require("express");
const router = express.Router();
const { askAssistant } = require("../controllers/chatbotController");

router.post("/ask", askAssistant);

module.exports = router;
