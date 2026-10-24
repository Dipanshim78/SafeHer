# 🚨 SafeHer Backend
A backend system for SafeHer, a women safety app that provides SOS alerts, authentication, and emergency contact features.

## Features
- User Authentication (JWT)
- SOS Alert System
- Contact Management

 ## Tech Stack
- Node.js
- Express.js
- MongoDB

  ## Installation

From the repository root:

```sh
cd backend
npm install
```

## Environment Variables

PORT=5000  
MONGO_URI=your_mongodb_url  
JWT_SECRET=replace_with_a_long_random_secret  
TWILIO_SID=your_twilio_account_sid  
TWILIO_AUTH_TOKEN=your_twilio_auth_token  
TWILIO_PHONE=your_twilio_phone_number
ORS_API_KEY=your_rotated_openrouteservice_key

## Run

npm start

The API starts on port `5000` by default. `GET /api/health` reports whether MongoDB is connected. Twilio notifications require valid credentials and an internet connection; without them, alerts are still recorded but no SMS is sent.

Map place search uses OpenStreetMap Nominatim, nearby emergency services use Overpass, and walking routes use OpenRouteService. Put the ORS key in the ignored `backend/.env` file; never put it in Flutter code or send it in chat. Revoke any key previously shared publicly.

Run backend tests with `npm test`.

## API

POST /api/auth/register  
POST /api/auth/login

Map endpoints: `GET /api/map/search?q=...`, `POST /api/map/route` with `start`/`end` `[longitude, latitude]` coordinates, and `GET /api/map/nearby?lat=...&lon=...`.

