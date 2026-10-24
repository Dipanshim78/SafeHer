const jwt = require("jsonwebtoken");//impoting JWT library JWT means JSON  Web Token

module.exports = (req, res, next) => {// creating middleware function Next() means ->  go next step(controller)
  const authorization = req.header("Authorization");
  const token = authorization && authorization.startsWith("Bearer ")
    ? authorization.slice(7)
    : authorization;

  if (!token) return res.status(401).json({ msg: "No token" });
  if (!process.env.JWT_SECRET) {
    return res.status(503).json({ msg: "Authentication is temporarily unavailable" });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    res.status(401).json({ msg: "Invalid token" });
  }
};
