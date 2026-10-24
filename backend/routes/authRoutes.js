const express = require("express");//using express framework
const router = express.Router();//mini route system
const { register, login, forgotPassword, resetPassword, me,  updateProfile } = require("../controllers/authController");//importing functions
const auth = require("../middleware/authMiddleware");

router.post("/register", register);//when request come to post/register,, it runs- register controllers 
router.post("/login", login);//when request come to POST/login It runs: login controller
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);
router.get("/me", auth, me);
router.put("/profile", auth, updateProfile);
module.exports = router;//so it can be used in main server