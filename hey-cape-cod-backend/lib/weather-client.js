const userAgent = process.env.NOAA_USER_AGENT || 'HeyCapeCodeApp/1.0';

/**
 * Fetch weather from NOAA Weather API (api.weather.gov).
 * Free, no API key required. Requires User-Agent header.
 *
 * Flow: GET /points/{lat},{lng} → get forecast URLs → fetch forecasts
 */
async function fetchWeather(lat, lng) {
  // Step 1: Get grid point metadata
  const pointRes = await fetch(
    `https://api.weather.gov/points/${lat},${lng}`,
    { headers: { 'User-Agent': userAgent } }
  );

  if (!pointRes.ok) {
    throw new Error(`NOAA points API returned ${pointRes.status}`);
  }

  const pointData = await pointRes.json();
  const { forecast: forecastUrl, forecastHourly: hourlyUrl } =
    pointData.properties;

  // Step 2: Fetch daily and hourly forecasts in parallel
  const [dailyRes, hourlyRes] = await Promise.all([
    fetch(forecastUrl, { headers: { 'User-Agent': userAgent } }),
    fetch(hourlyUrl, { headers: { 'User-Agent': userAgent } }),
  ]);

  if (!dailyRes.ok || !hourlyRes.ok) {
    throw new Error('Failed to fetch NOAA forecasts');
  }

  const [dailyData, hourlyData] = await Promise.all([
    dailyRes.json(),
    hourlyRes.json(),
  ]);

  // Step 3: Parse into our format
  const hourlyPeriods = hourlyData.properties.periods || [];
  const dailyPeriods = dailyData.properties.periods || [];

  const current = hourlyPeriods[0];
  const currentWeather = current
    ? {
        temperature: current.temperature,
        temperatureUnit: current.temperatureUnit,
        feelsLike: current.temperature,
        condition: mapCondition(current.shortForecast),
        conditionDescription: current.shortForecast,
        humidity: current.relativeHumidity?.value || 0,
        windSpeed: current.windSpeed,
        windDirection: current.windDirection,
        icon: current.icon,
        isDaytime: current.isDaytime,
      }
    : null;

  const hourly = hourlyPeriods.slice(0, 24).map((p) => ({
    time: p.startTime,
    temperature: p.temperature,
    condition: mapCondition(p.shortForecast),
    conditionDescription: p.shortForecast,
    precipChance: p.probabilityOfPrecipitation?.value || 0,
    windSpeed: p.windSpeed,
    isDaytime: p.isDaytime,
  }));

  // Pair day/night periods for daily forecast
  const daily = [];
  for (let i = 0; i < dailyPeriods.length - 1; i += 2) {
    const day = dailyPeriods[i];
    const night = dailyPeriods[i + 1];
    if (day && night) {
      daily.push({
        date: day.startTime,
        name: day.name,
        high: day.temperature,
        low: night.temperature,
        condition: mapCondition(day.shortForecast),
        conditionDescription: day.shortForecast,
        precipChance: day.probabilityOfPrecipitation?.value || 0,
      });
    }
  }

  return {
    current: currentWeather,
    hourly,
    daily,
    location: { lat, lng },
    fetchedAt: new Date().toISOString(),
  };
}

function mapCondition(forecast) {
  if (!forecast) return 'clear';
  const lower = forecast.toLowerCase();
  if (lower.includes('thunder')) return 'thunderstorm';
  if (lower.includes('rain') || lower.includes('shower')) return 'rain';
  if (lower.includes('snow')) return 'snow';
  if (lower.includes('fog') || lower.includes('mist')) return 'fog';
  if (lower.includes('wind')) return 'windy';
  if (lower.includes('cloud') || lower.includes('overcast')) return 'cloudy';
  if (lower.includes('partly')) return 'partlyCloudy';
  return 'clear';
}

module.exports = { fetchWeather };
