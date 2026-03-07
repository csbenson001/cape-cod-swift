/**
 * NOAA CO-OPS Tide API client.
 * Free, no API key required.
 *
 * Docs: https://api.tidesandcurrents.noaa.gov/api/prod/
 */

const BASE_URL = 'https://api.tidesandcurrents.noaa.gov/api/prod/datagetter';

/**
 * Fetch tide predictions for a given NOAA station.
 * Returns hi/lo tide predictions for the next 72 hours.
 *
 * @param {string} stationId - NOAA station ID (e.g. "8447930" for Woods Hole)
 */
async function fetchTides(stationId) {
  const today = formatDate(new Date());

  const params = new URLSearchParams({
    begin_date: today,
    range: '72',
    station: stationId,
    product: 'predictions',
    datum: 'MLLW',
    time_zone: 'lst_ldt',
    interval: 'hilo',
    units: 'english',
    application: 'HeyCapeCode',
    format: 'json',
  });

  const res = await fetch(`${BASE_URL}?${params}`);

  if (!res.ok) {
    throw new Error(`NOAA Tides API returned ${res.status}`);
  }

  const data = await res.json();

  if (!data.predictions || !Array.isArray(data.predictions)) {
    throw new Error('Invalid tide prediction response');
  }

  const predictions = data.predictions.map((p) => ({
    time: p.t,
    height: parseFloat(p.v),
    type: p.type, // "H" or "L"
  }));

  return {
    stationId,
    predictions,
    fetchedAt: new Date().toISOString(),
  };
}

function formatDate(date) {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}${m}${d}`;
}

module.exports = { fetchTides };
