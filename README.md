# SafeHer 🚺

## 📌 Problem Statement
In emergency situations, women often do not have the time to unlock their phones, open an app, and manually send an alert. **SafeHer** provides voice-activated SOS and location-aware emergency notifications when the app and backend have network access.

## 🚀 Features
- **Voice SOS 🎤**: Starts the SOS countdown when the app is open, voice listening is enabled, and the device recognizes the trigger word (such as *"help"*).
- **Emergency Alert (SMS) 📩**: Records SOS alerts and sends SMS notifications to trusted contacts through Twilio when backend credentials and an internet connection are available. Offline GSM SMS is not implemented.
- **Live Location Tracking 🌍**: Instantly captures the user's highest-accuracy GPS location when in danger.
- **Emergency Contacts 📱**: User-friendly interface to manage up to multiple trusted family members or friends.

## 📱 How to Use the App
1. **Create an Account:** Open the app and **Signup** using your Name, Email, and Phone number.
2. **Add Emergency Contacts:** Go to the *Emergency Contacts* section (Phone Icon) and add the phone numbers of your trusted family or friends.
3. **Manual SOS:** On the Home Page, tap the large red **SOS** button. It will count down for 3 seconds (giving you a chance to cancel) before grabbing your live GPS coordinates and texting your contacts via Twilio.
4. **Voice SOS:** Tap the **Mic** icon while the app is open. Say the word **"help"** to start the SOS countdown. Speech recognition support depends on the device and may require internet.

## 💻 Tech Stack
- **Frontend**: Flutter (Cross-platform UI)
- **Backend**: Node.js & Express (Robust APIs)
- **Database**: MongoDB (Secure cloud storage for users/contacts)
- **Communications**: Twilio SMS API (requires internet access)

## 🛠️ How to Run the Project Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- [Node.js](https://nodejs.org/) installed.
- A free [MongoDB Atlas](https://www.mongodb.com/) cluster URL.
- A free Twilio Account for SMS API keys.

### 1. Clone the Repository
Open your terminal and clone the repository to your local machine:
```bash
git clone https://github.com/aayu-collab/SafeHer2.O.git
cd SafeHer2.O
```

### 2. Setup the Backend (Node.js)
1. Open a terminal and navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install the required Node dependencies:
   ```bash
   npm install
   ```
3. Create a `.env` file in the `backend` folder and add your credentials:
   ```env
   MONGO_URI=your_mongodb_connection_string
   JWT_SECRET=your_jwt_secret_key
   PORT=5000
   TWILIO_SID=your_twilio_account_sid
   TWILIO_AUTH_TOKEN=your_twilio_auth_token
   TWILIO_PHONE=your_twilio_phone_number
   ```
4. Start the backend server:
   ```bash
   npm start
   ```
5. Run backend tests:
   ```bash
   npm test
   ```

### 2. Setup the Frontend (Flutter)
1. Open a new terminal and navigate to the Flutter project folder:
   ```bash
   cd "frontend/safeher project/my_app"
   ```
2. Download all the required Flutter packages:
   ```bash
   flutter pub get
   ```
3. Check the app and run its tests:
   ```bash
   flutter analyze
   flutter test
   ```
4. Run the app on an Emulator or Google Chrome:
   ```bash
   flutter run
   ```
   Enter phone numbers in international format (for example, `+15551234567`). Android emulators reach the local backend through `10.0.2.2`; iOS simulators and web use localhost. For local development, run `flutter run` without setting `API_BASE_URL`. Production deployments must use HTTPS and the real URL of your deployed backend; do not enter the example `your-api-host` literally.
![image alt](https://github.com/aayu-collab/SafeHer2.O/blob/d70f8c7a3bc46e866228c1eb49710872359c4447/Screenshot%202026-04-11%20060507.png)
![image alt](https://github.com/aayu-collab/SafeHer2.O/blob/461a7af44bfe0dbf848254a5c3201ab14aae42f2/Screenshot%202026-04-11%20060615.png)
![image alt](https://github.com/aayu-collab/SafeHer2.O/blob/a9af3178199656ec1b9440579dea4f3e01271d71/Screenshot%202026-04-11%20060710.png)
![image alt](https://github.com/aayu-collab/SafeHer2.O/blob/943c1df078879b3357777b52bc824233cc28b8d8/Screenshot%202026-04-11%20060855.png)
![image alt](https://github.com/aayu-collab/SafeHer2.O/blob/2d3ae8c203f6f82cf5f2d1829856ebca98e696da/Screenshot%202026-04-11%20060918.png)
## 🛡️ License
This project is open-source and intended to contribute to community safety.
