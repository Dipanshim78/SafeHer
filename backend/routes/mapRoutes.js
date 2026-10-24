const express = require("express");
const { nearbyServices, routeWalking, searchPlaces } = require("../utils/mapHelper");

const router = express.Router();

const handle = (action) => async (req, res) => {
  try {
    res.json(await action(req));
  } catch (error) {
    res.status(error.status || 502).json({ msg: error.message || "Map service unavailable" });
  }
};

router.get("/search", handle((req) => searchPlaces(req.query.q)));
router.post("/route", handle((req) => routeWalking(req.body?.start, req.body?.end)));
router.get("/nearby", handle((req) => nearbyServices(req.query.lat, req.query.lon)));

module.exports = router;