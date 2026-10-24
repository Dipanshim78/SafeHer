const NOMINATIM_URL = "https://nominatim.openstreetmap.org/search";
const ORS_ROUTE_URL = "https://api.openrouteservice.org/v2/directions/foot-walking/geojson";
const OSM_FOOT_ROUTE_URL = "https://routing.openstreetmap.de/routed-foot/route/v1/driving";
const OVERPASS_URL = "https://overpass-api.de/api/interpreter";

const validCoordinate = (value, min, max) =>
	Number.isFinite(value) && value >= min && value <= max;

const parsePoint = (point, label) => {
	if (!Array.isArray(point) || point.length !== 2) {
		const error = new Error(`${label} must be [longitude, latitude]`);
		error.status = 400;
		throw error;
	}

	const [longitude, latitude] = point.map(Number);
	if (!validCoordinate(longitude, -180, 180) || !validCoordinate(latitude, -90, 90)) {
		const error = new Error(`${label} coordinates are invalid`);
		error.status = 400;
		throw error;
	}
	return [longitude, latitude];
};

const requestJson = async (url, options) => {
	const response = await fetch(url, options);
	if (!response.ok) {
		const error = new Error(`Map provider request failed (${response.status})`);
		error.status = response.status === 429 ? 429 : 502;
		throw error;
	}
	return response.json();
};

const searchPlaces = async (query) => {
	const text = String(query || "").trim();
	if (text.length < 2 || text.length > 200) {
		const error = new Error("Search query must be between 2 and 200 characters");
		error.status = 400;
		throw error;
	}

	const url = new URL(NOMINATIM_URL);
	url.search = new URLSearchParams({ q: text, format: "jsonv2", limit: "5" });
	const results = await requestJson(url, {
		headers: { "User-Agent": "SafeHer/1.0 (safety route search)" },
	});

	return results.map((place) => ({
		name: place.display_name,
		latitude: Number(place.lat),
		longitude: Number(place.lon),
	}));
};

const routeWalking = async (start, end) => {
	const coordinates = [parsePoint(start, "start"), parsePoint(end, "end")];
	const apiKey = process.env.ORS_API_KEY;
	let routeData;

	if (apiKey) {
		const payload = await requestJson(ORS_ROUTE_URL, {
			method: "POST",
			headers: {
				Authorization: apiKey,
				"Content-Type": "application/json",
				Accept: "application/geo+json",
			},
			body: JSON.stringify({
				coordinates,
				alternative_routes: { target_count: 3, weight_factor: 1.4, share_factor: 0.6 },
			}),
		});
		routeData = (payload.features || []).map((feature) => ({
			line: feature.geometry?.coordinates,
			distance: feature.properties?.summary?.distance,
			duration: feature.properties?.summary?.duration,
		}));
	} else {
		const points = coordinates.map(([longitude, latitude]) => `${longitude},${latitude}`).join(";");
		const url = `${OSM_FOOT_ROUTE_URL}/${points}?overview=full&geometries=geojson&steps=false&alternatives=true`;
		const payload = await requestJson(url);
		routeData = (payload.routes || []).map((route) => ({
			line: route.geometry?.coordinates,
			distance: route.distance,
			duration: route.duration,
		}));
	}

	const alternatives = routeData
		.filter((route) => Array.isArray(route.line) && route.line.length > 1 &&
			Number.isFinite(route.distance) && Number.isFinite(route.duration))
		.slice(0, 3)
		.map((route, index) => ({
			routeId: index + 1,
			points: route.line.map(([longitude, latitude]) => ({ latitude, longitude })),
			distanceMeters: Math.round(route.distance),
			durationSeconds: Math.round(route.duration),
		}));

	if (alternatives.length === 0) {
		const error = new Error("Walking route provider returned no route");
		error.status = 502;
		throw error;
	}

	return { ...alternatives[0], alternatives };
};

const compareRouteEmergencyCoverage = async (routes) => {
	const samplePoints = routes.flatMap((route) => {
		const points = route.points;
		const count = Math.min(4, points.length);
		return Array.from({ length: count }, (_, index) =>
			points[Math.round(index * (points.length - 1) / Math.max(count - 1, 1))]);
	});
	if (samplePoints.length === 0) return routes;

	const aroundQueries = samplePoints.map(({ latitude, longitude }) =>
		`node[amenity~"^(police|hospital|clinic)$"](around:400,${latitude},${longitude});way[amenity~"^(police|hospital|clinic)$"](around:400,${latitude},${longitude});relation[amenity~"^(police|hospital|clinic)$"](around:400,${latitude},${longitude});`,
	).join("");
	const payload = await requestJson(OVERPASS_URL, {
		method: "POST",
		headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
		body: new URLSearchParams({ data: `[out:json][timeout:20];(${aroundQueries});out center tags;` }),
	});

	const facilities = new Map();
	for (const place of payload.elements || []) {
		const latitude = Number(place.lat ?? place.center?.lat);
		const longitude = Number(place.lon ?? place.center?.lon);
		const type = place.tags?.amenity;
		if (!Number.isFinite(latitude) || !Number.isFinite(longitude) || !["police", "hospital", "clinic"].includes(type)) continue;
		const key = `${place.type}:${place.id}`;
		facilities.set(key, {
			name: place.tags?.name || `Unnamed ${type}`,
			type,
			latitude,
			longitude,
		});
	}

	const distanceMeters = (first, second) => {
		const latitudeDelta = (first.latitude - second.latitude) * Math.PI / 180;
		const longitudeDelta = (first.longitude - second.longitude) * Math.PI / 180;
		const firstLatitude = first.latitude * Math.PI / 180;
		const secondLatitude = second.latitude * Math.PI / 180;
		const a = Math.sin(latitudeDelta / 2) ** 2 + Math.cos(firstLatitude) * Math.cos(secondLatitude) * Math.sin(longitudeDelta / 2) ** 2;
		return 6371000 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
	};

	return routes.map((route) => {
		const sampled = route.points.filter((_, index) =>
			index % Math.max(1, Math.ceil(route.points.length / 24)) === 0);
		const nearby = [...facilities.values()].map((facility) => ({
			...facility,
			distanceMeters: Math.round(Math.min(...sampled.map((point) => distanceMeters(point, facility)))),
		})).filter((facility) => facility.distanceMeters <= 400);
		const policeCount = nearby.filter((facility) => facility.type === "police").length;
		const hospitalCount = nearby.filter((facility) => facility.type === "hospital" || facility.type === "clinic").length;
		return {
			...route,
			nearbyPoliceCount: policeCount,
			nearbyHospitalCount: hospitalCount,
			mappedEmergencySupport: policeCount * 2 + hospitalCount,
		};
	});
};

const nearbyServices = async (latitude, longitude) => {
	const lat = Number(latitude);
	const lon = Number(longitude);
	if (!validCoordinate(lat, -90, 90) || !validCoordinate(lon, -180, 180)) {
		const error = new Error("A valid latitude and longitude are required");
		error.status = 400;
		throw error;
	}

	const query = `[out:json][timeout:15];(node[amenity~"^(police|hospital|clinic)$"](around:5000,${lat},${lon});way[amenity~"^(police|hospital|clinic)$"](around:5000,${lat},${lon});relation[amenity~"^(police|hospital|clinic)$"](around:5000,${lat},${lon}););out center tags;`;
	const payload = await requestJson(OVERPASS_URL, {
		method: "POST",
		headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
		body: new URLSearchParams({ data: query }),
	});

	const places = (payload.elements || []).map((place) => ({
		name: place.tags?.name || "Unnamed emergency service",
		type: place.tags?.amenity || "emergency service",
		latitude: Number(place.lat ?? place.center?.lat),
		longitude: Number(place.lon ?? place.center?.lon),
	})).filter((place) => Number.isFinite(place.latitude) && Number.isFinite(place.longitude));

	const distanceFromOrigin = (place) => {
		const latitudeDelta = (place.latitude - lat) * Math.PI / 180;
		const longitudeDelta = (place.longitude - lon) * Math.PI / 180;
		const originLatitude = lat * Math.PI / 180;
		const placeLatitude = place.latitude * Math.PI / 180;
		const a = Math.sin(latitudeDelta / 2) ** 2 +
			Math.cos(originLatitude) * Math.cos(placeLatitude) *
			Math.sin(longitudeDelta / 2) ** 2;
		return 6371000 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
	};

	return places
		.map((place) => ({ ...place, distanceMeters: Math.round(distanceFromOrigin(place)) }))
		.sort((first, second) => first.distanceMeters - second.distanceMeters);
};

module.exports = { compareRouteEmergencyCoverage, nearbyServices, routeWalking, searchPlaces };
