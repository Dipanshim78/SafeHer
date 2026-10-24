const express = require("express");// using express framework 
const router = express.Router();//creates a mini router(used to defined routes)
const auth = require("../middleware/authMiddleware");//our JSON web token middleware(this will check token and authenticate user)
const { sendAlert } = require("../controllers/alertController");//importing contact that contains main logic

router.post("/send", auth, sendAlert);///MOST IMP LINE (when request come to /send -> 1. auth middleware runs 2. if valid -> sendAlert controller runs)

module.exports = router;//so it can be used in main server