const SAFETY_PROMPT = `You are SafeHer Assistant, a warm, conversational safety assistant. Reply in the same language as the user. Use the supplied conversation history to answer follow-up questions naturally and avoid repeating yourself. Give concise, specific, practical advice. Do not treat a greeting, vague question, or general request for help as an emergency; ask what the user wants to know. Give urgent instructions only when the user describes immediate danger. Never claim a place or route is safe without evidence. Only name nearby facilities if present in supplied OpenStreetMap results. For route comparisons, explain the evidence and limitations clearly.`;
const { compareRouteEmergencyCoverage, nearbyServices, routeWalking, searchPlaces } = require("../utils/mapHelper");

const needsNearbyServices = (message = "") =>
  /(?:\b(near(?:by|est)?|around me|police|hospital|clinic|emergency room)\b|पास|नज़दीक|नजदीक|अस्पताल|थाना)/i.test(message);

const needsRouteAdvice = (message = "") =>
  /\b(route|directions|walking route|which way|how do i get|go to|travel to|safe way|rasta|raasta|jana hai|jaana hai)\b|रास्ता|रास्ते|रूट|जाना है|जाना चाहती/i.test(message);

const isImmediateDanger = (message = "") =>
  /\b(immediate danger|in danger right now|unsafe right now|someone is following me|being followed|attacked|threatened me|help me now|emergency right now)\b|अभी खतरे में|अभी असुरक्षित|मेरा पीछा कर रहा|मेरे पीछे पड़ा|(?:mujhe|main)\s+abhi\s+(?:khatra|danger)|koi\s+(?:mera\s+)?peecha\s+kar\s+raha/i.test(message);

const isVagueOpening = (message = "") =>
  /^(hi|hello|hey|help|help me|i need help|can you help me|what can you do|i feel unsafe|i feel scared|i am scared|i'm scared|मदद|मुझे मदद चाहिए|मुझे डर लग रहा है|हेलो|नमस्ते)[.!?\s]*$/i.test(message.trim());

const extractDestination = (message, history = []) => {
  const userTurns = [...history.filter((turn) => turn.role === "user").map((turn) => turn.content), message];
  const combined = userTurns.join(" ");
  const toMatches = [...combined.matchAll(/\bto\s+([^,.!?]+)/gi)];
  if (toMatches.length) return toMatches[toMatches.length - 1][1].trim();

  const lastTurn = message.trim();
  const hindiDestination = lastTurn.match(/(?:mujhe\s+)?(.+?)\s+(?:tak\s+)?(?:jana|jaana)\s+hai/i);
  if (hindiDestination) return hindiDestination[1].trim();

  const routeWasDiscussed = userTurns.slice(0, -1).some(needsRouteAdvice);
  if (routeWasDiscussed && lastTurn.length > 2 && !/^(yes|yeah|ok|okay|haan|ha|नहीं|नही)$/i.test(lastTurn)) {
    return lastTurn;
  }
  return "";
};

const sanitizeHistory = (history) => {
  if (!Array.isArray(history)) return [];

  return history.slice(-12).flatMap((turn) => {
    if (!turn || !["user", "assistant"].includes(turn.role) || typeof turn.content !== "string") return [];
    const content = turn.content.trim().slice(0, 1500);
    return content ? [{ role: turn.role, content }] : [];
  });
};

const isValidLocation = (latitude, longitude) =>
  Number.isFinite(latitude) && latitude >= -90 && latitude <= 90 &&
  Number.isFinite(longitude) && longitude >= -180 && longitude <= 180;

const summarizeNearbyServices = (places = []) => {
  const police = places.find((place) => place.type === "police");
  const hospital = places.find((place) => place.type === "hospital");
  const clinic = places.find((place) => place.type === "clinic");
  const lines = [];

  for (const [label, place] of [["Police", police], ["Hospital", hospital || clinic]]) {
    if (!place) {
      lines.push(`${label}: no nearby listing found in OpenStreetMap data.`);
      continue;
    }
    const distance = place.distanceMeters < 1000
      ? `${place.distanceMeters} m`
      : `${(place.distanceMeters / 1000).toFixed(1)} km`;
    const mapUrl = `https://www.openstreetmap.org/?mlat=${place.latitude}&mlon=${place.longitude}#map=17/${place.latitude}/${place.longitude}`;
    lines.push(`${label}: ${place.name}, about ${distance} away. Map: ${mapUrl}`);
  }

  return lines.join("\n");
};

const generateSafetyReply = (message = "", nearbyText = "", locationRequested = false) => {
  const text = String(message).trim().toLowerCase();
  let reply;

  if (isImmediateDanger(text)) {
    reply = "If you may be in immediate danger, move toward a staffed public place, call 112 in India, and contact someone you trust. Use the app's SOS if you need to alert your saved contacts.";
  } else if (/sos|alert/.test(text)) {
    reply = "Use the SOS button on the home screen to notify your saved emergency contacts. If there is immediate danger, call 112 in India now.";
  } else {
    reply = "What would you like to know? I can help with safety planning, SOS, nearby police or hospitals, or comparing walking routes.";
  }

  if (locationRequested && !nearbyText) {
    reply += " Allow location access so I can look up actual nearby police and hospital listings.";
  }
  return nearbyText ? `${reply}\n\nNearby listings from OpenStreetMap (check availability before relying on them):\n${nearbyText}` : reply;
};

const formatRouteComparison = (routes, destination, hasFacilityEvidence) => {
  const options = [...routes].sort((first, second) => {
    if (hasFacilityEvidence && first.mappedEmergencySupport !== second.mappedEmergencySupport) {
      return second.mappedEmergencySupport - first.mappedEmergencySupport;
    }
    return first.durationSeconds - second.durationSeconds;
  });
  const recommended = options[0];
  const lines = options.map((route, index) => {
    const distance = `${(route.distanceMeters / 1000).toFixed(1)} km`;
    const duration = `${Math.max(1, Math.round(route.durationSeconds / 60))} min`;
    const evidence = hasFacilityEvidence
      ? `; mapped nearby police ${route.nearbyPoliceCount}, hospital/clinic ${route.nearbyHospitalCount}`
      : "";
    return `Route ${index + 1}: ${distance}, about ${duration}${evidence}.`;
  });
  const reason = hasFacilityEvidence
    ? `Route 1 has the strongest mapped emergency-service presence near sampled route sections. This is only map data, not a guarantee that it is safest.`
    : `I cannot reliably label any option as safest because no nearby emergency-service data was found along the sampled sections. Route 1 is the shortest-time option, not a safety guarantee.`;
  return `I found ${options.length} walking option${options.length === 1 ? "" : "s"} to ${destination}. ${reason}\n${lines.join("\n")}`;
};

const appendLocationContext = (reply, nearbyText, routeComparison, locationRequested, latitude, longitude) => {
  if (routeComparison) return `${reply}\n\n${routeComparison}`;
  if (nearbyText) return `${reply}\n\nNearby listings from OpenStreetMap (check availability before relying on them):\n${nearbyText}`;
  if (locationRequested && !isValidLocation(latitude, longitude)) {
    return `${reply}\n\nAllow location access to look up actual nearby police and hospital listings.`;
  }
  return reply;
};

const getPreferredProvider = () => {
  const provider = (process.env.AI_PROVIDER || "openai").toLowerCase();
  if (provider === "gemini" && process.env.GEMINI_API_KEY) return "gemini";
  if (provider === "openai" && process.env.OPENAI_API_KEY) return "openai";
  if (process.env.GEMINI_API_KEY) return "gemini";
  if (process.env.OPENAI_API_KEY) return "openai";
  return "local";
};

// const askOpenAI = async (messages) => {
//   const apiKey = process.env.OPENAI_API_KEY;
//   if (!apiKey) return null;

//   const attempts = [
//     {
//       url: "https://api.openai.com/v1/chat/completions",
//       body: {
//         model: "gpt-4o-mini",
//         messages,
//       },
//       parser: (payload) => payload?.choices?.[0]?.message?.content,
//     },
//     {
//       url: "https://api.openai.com/v1/responses",
//       body: {
//         model: "gpt-4o-mini",
//         input: messages,
//       },
//       parser: (payload) => payload?.output?.[0]?.content?.[0]?.text || payload?.output_text,
//     },
//   ];

//   for (const attempt of attempts) {
//     const response = await fetch(attempt.url, {
//       method: "POST",
//       headers: {
//         "Content-Type": "application/json",
//         Authorization: `Bearer ${apiKey}`,
//       },
//       body: JSON.stringify(attempt.body),
//     });

//     if (!response.ok) {
//       continue;
//     }

//     const payload = await response.json();
//     const reply = attempt.parser(payload);
//     if (reply) {
//       return { reply: String(reply), source: "openai" };
//     }
//   }

//   throw new Error("OpenAI response did not contain text");
// };
const askOpenAI = async (messages) => {
  const apiKey = process.env.OPENAI_API_KEY;

  if (!apiKey) {
    return null;
  }

  const response = await fetch(
    "https://api.openai.com/v1/chat/completions",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages,
        temperature: 0.7,
        max_tokens: 500,
      }),
    }
  );

  const payload = await response.json();

  if (!response.ok) {
    console.error(
      "OpenAI API error:",
      payload?.error?.message || "Unknown OpenAI error"
    );

    throw new Error(
      payload?.error?.message || `OpenAI request failed: ${response.status}`
    );
  }

  const reply = payload?.choices?.[0]?.message?.content?.trim();

  if (!reply) {
    console.error(
      "OpenAI unexpected response:",
      JSON.stringify(payload, null, 2)
    );

    throw new Error("OpenAI response did not contain text");
  }

  return {
    reply,
    source: "openai",
  };
};
// const askGemini = async (messages) => {
//   const apiKey = process.env.GEMINI_API_KEY;
//   if (!apiKey) return null;

//   const systemPrompt = messages.find((item) => item.role === "system")?.content || SAFETY_PROMPT;
//   const contents = messages
//     .filter((item) => item.role !== "system")
//     .map((item) => ({
//       role: item.role === "assistant" ? "model" : "user",
//       parts: [{ text: item.content }],
//     }));

//   const response = await fetch(
//     `https://generativelanguage.googleapis.com/v1beta/models/${process.env.GEMINI_MODEL || "gemini-2.5-flash"}:generateContent?key=${apiKey}`,
//     {
//       method: "POST",
//       headers: { "Content-Type": "application/json" },
//       body: JSON.stringify({
//         systemInstruction: { parts: [{ text: systemPrompt }] },
//         contents,
//       }),
//     },
//   );

//   if (!response.ok) {
//     throw new Error(`Gemini request failed: ${response.status}`);
//   }

//   const payload = await response.json();
//   const reply = payload?.candidates?.[0]?.content?.parts?.[0]?.text;
//   if (!reply) {
//     throw new Error("Gemini response did not contain text");
//   }

//   return { reply, source: "gemini" };
// };
const askGemini = async (messages) => {
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    return null;
  }

  const systemPrompt =
    messages.find((item) => item.role === "system")?.content ||
    SAFETY_PROMPT;

  const contents = messages
    .filter((item) => item.role !== "system")
    .map((item) => ({
      role: item.role === "assistant" ? "model" : "user",
      parts: [{ text: item.content }],
    }));

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        systemInstruction: {
          parts: [{ text: systemPrompt }],
        },
        contents,
      }),
    }
  );

  const payload = await response.json();

  if (!response.ok) {
    console.error(
      "Gemini API error:",
      payload?.error?.message || JSON.stringify(payload)
    );

    throw new Error(
      `Gemini request failed: ${
        payload?.error?.message || response.status
      }`
    );
  }

  const reply =
    payload?.candidates?.[0]?.content?.parts?.[0]?.text?.trim();

  if (!reply) {
    console.error(
      "Gemini unexpected response:",
      JSON.stringify(payload, null, 2)
    );

    throw new Error("Gemini response did not contain text");
  }

  return {
    reply,
    source: "gemini",
  };
};
const askAssistant = async (req, res) => {
  const rawMessage = req.body?.message;
  const message = typeof rawMessage === "string" ? rawMessage.trim() : "";

  if (!message) {
    return res.status(400).json({ msg: "Message is required" });
  }

  const history = sanitizeHistory(req.body?.history);
  const hindiInput = /[\u0900-\u097f]/.test(message);
  if (isVagueOpening(message)) {
    const reply = hindiInput
      ? "Kya aap abhi turant khatre mein ho? Batao kis cheez mein help chahiye—safety steps, paas ka police station/hospital, ya walking route compare karna. Turant khatra ho to 112 call karo."
      : "Are you in immediate danger right now? Tell me what you need help with: safety steps, nearby police or hospital, or comparing walking routes. If there is immediate danger, call 112.";
    return res.status(200).json({ reply, source: "clarification" });
  }

  if (isImmediateDanger(message)) {
    const reply = hindiInput
      ? "Agar abhi turant khatra hai, bheed ya staffed public jagah par jao, 112 call karo, aur kisi bharosemand vyakti ko batao. Zarurat ho to app ka SOS use karo."
      : "If you are in immediate danger, move to a staffed public place, call 112 in India, and contact someone you trust. Use the app SOS if needed.";
    return res.status(200).json({ reply, source: "urgent-guidance" });
  }

  const routeRequested = needsRouteAdvice(message) || history.some((turn) => turn.role === "user" && needsRouteAdvice(turn.content));
  const destination = routeRequested ? extractDestination(message, history) : "";
  if (routeRequested && !destination) {
    const reply = hindiInput
      ? "Zaroor. Aap kahan jana chahte ho? Destination batao; current GPS ko starting point lekar available walking routes compare karunga."
      : "Sure. Where are you going? Tell me the destination; I can use your current GPS as the start and compare available walking routes.";
    return res.status(200).json({ reply, source: "clarification" });
  }

  const locationRequested = needsNearbyServices(message) || routeRequested;
  const latitude = req.body?.latitude;
  const longitude = req.body?.longitude;
  let nearbyText = "";
  let routeComparison = "";

  if (routeRequested && !isValidLocation(latitude, longitude)) {
    const reply = hindiInput
      ? `Destination ${destination} mil gaya. Current location permission allow karo, tab main walking routes compare kar paunga.`
      : `I found the destination “${destination}”. Allow current-location access so I can compare walking routes from your position.`;
    return res.status(200).json({ reply, source: "clarification" });
  }

  if (routeRequested) {
    try {
      const places = await searchPlaces(destination);
      if (places.length === 0) {
        return res.status(200).json({
          reply: `I couldn't find “${destination}”. Please share the place name and city so I can compare routes accurately.`,
          source: "clarification",
        });
      }
      const place = places[0];
      const routeResult = await routeWalking(
        [longitude, latitude],
        [place.longitude, place.latitude],
      );
      let alternatives = routeResult.alternatives;
      let hasFacilityEvidence = false;
      try {
        alternatives = await compareRouteEmergencyCoverage(alternatives);
        hasFacilityEvidence = alternatives.some((route) => route.mappedEmergencySupport > 0);
      } catch (error) {
        console.error("Route safety-data comparison failed:", error.message);
      }
      routeComparison = formatRouteComparison(alternatives, place.name, hasFacilityEvidence);
    } catch (error) {
      return res.status(200).json({
        reply: `I couldn't compare walking routes right now: ${error.message}. You can still use the map section to choose a destination.`,
        source: "local",
      });
    }

    return res.status(200).json({ reply: routeComparison, source: "route-comparison" });
  }

  if (locationRequested && !isValidLocation(latitude, longitude)) {
    const reply = hindiInput
      ? "Asli paas ke police station aur hospital dhoondhne ke liye current location chahiye. Chrome address bar ke paas site controls icon kholo, Location ko Allow karo, page reload karke phir poochho. Main jagah ke naam guess nahi karunga. Turant emergency ho to 112 call karo."
      : "To find actual nearby police stations and hospitals, I need your current location. In Chrome, open the site controls icon beside the address bar, set Location to Allow, reload the page, then ask again. I won't guess place names. If this is urgent, call 112.";
    return res.status(200).json({ reply, source: "location-required" });
  }

  if (locationRequested) {
    try {
      nearbyText = summarizeNearbyServices(await nearbyServices(latitude, longitude));
    } catch (error) {
      console.error("Nearby service lookup failed:", error.message);
      return res.status(200).json({
        reply: "I couldn't load nearby OpenStreetMap listings just now. Try again shortly; if this is urgent, call 112.",
        source: "openstreetmap-unavailable",
      });
    }
    return res.status(200).json({
      reply: `Nearby listings from OpenStreetMap (confirm details before relying on them):\n${nearbyText}`,
      source: "openstreetmap",
    });
  }

  const systemPrompt = [
    SAFETY_PROMPT,
    nearbyText ? `Nearby OpenStreetMap results (not a safety certification):\n${nearbyText}\nUse these exact listings; never invent other places.` : "",
    routeComparison ? `Walking-route comparison:\n${routeComparison}\nExplain that this is mapped evidence, not a safety guarantee.` : "",
  ].filter(Boolean).join("\n\n");
  const messages = [
    { role: "system", content: systemPrompt },
    ...history,
    { role: "user", content: message },
  ];
  const provider = getPreferredProvider();
  let providerFailed = false;

  try {
    if (provider === "gemini") {
      const geminiResponse = await askGemini(messages);
      if (geminiResponse) {
        const reply = appendLocationContext(
          geminiResponse.reply,
          nearbyText,
          routeComparison,
          locationRequested,
          latitude,
          longitude,
        );
        return res.status(200).json({ ...geminiResponse, reply });
      }
    }

    if (provider === "openai") {
      const openAiResponse = await askOpenAI(messages);
      if (openAiResponse) {
        const reply = appendLocationContext(
          openAiResponse.reply,
          nearbyText,
          routeComparison,
          locationRequested,
          latitude,
          longitude,
        );
        return res.status(200).json({ ...openAiResponse, reply });
      }
    }
  } catch (error) {
    providerFailed = true;
    console.error(`AI provider error [${provider}]:`, error.message);
  }

  const isUrgent = isImmediateDanger(message);
  if (!isUrgent) {
    const status = provider === "local"
      ? "AI chat is not configured yet. Add an OpenAI or Gemini API key to backend/.env."
      : providerFailed
        ? "The AI provider is unavailable right now; check its API key, quota, or connection."
        : "The AI provider did not return a response. Please try again.";
    return res.status(200).json({
      reply: appendLocationContext(status, nearbyText, routeComparison, locationRequested, latitude, longitude),
      source: "local",
    });
  }

  return res.status(200).json({
    reply: generateSafetyReply(message, nearbyText, locationRequested),
    source: "local",
  });
};

module.exports = { askAssistant, generateSafetyReply, getPreferredProvider, sanitizeHistory };
