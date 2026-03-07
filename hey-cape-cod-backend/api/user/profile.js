const { withMiddleware } = require('../../lib/middleware');
const { getDoc, setDoc } = require('../../lib/firestore');
const { admin } = require('../../lib/firebase-admin');

const ALLOWED_FIELDS = ['displayName', 'currentMode', 'visitType', 'interests', 'favoritePoiIds'];
const VALID_MODES = ['adult', 'kids', 'teen', 'family'];
const VALID_VISIT_TYPES = ['first-time', 'tourist', 'local', 'dayTrip'];

module.exports = withMiddleware(async (req, res, log) => {
  const uid = req.uid;

  if (req.method === 'GET') {
    let user = await getDoc('users', uid);

    if (!user) {
      user = {
        uid,
        displayName: '',
        email: '',
        currentMode: 'adult',
        visitType: 'first-time',
        interests: [],
        isPremium: false,
        premiumExpiresAt: null,
        conversationsToday: 0,
        storiesPlayedToday: 0,
        lastUsageReset: admin.firestore.FieldValue.serverTimestamp(),
        triggeredStories: {},
        favoritePoiIds: [],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      await setDoc('users', uid, user);
      log.info('Created new user profile', { uid });
    }

    res.status(200).json(user);
  } else if (req.method === 'PUT') {
    const updates = {};
    for (const field of ALLOWED_FIELDS) {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'No valid fields to update' });
    }

    // Validate enum fields
    if (updates.currentMode && !VALID_MODES.includes(updates.currentMode)) {
      return res.status(400).json({ error: `Invalid mode. Must be one of: ${VALID_MODES.join(', ')}` });
    }
    if (updates.visitType && !VALID_VISIT_TYPES.includes(updates.visitType)) {
      return res.status(400).json({ error: `Invalid visitType. Must be one of: ${VALID_VISIT_TYPES.join(', ')}` });
    }
    if (updates.interests && (!Array.isArray(updates.interests) || updates.interests.length > 20)) {
      return res.status(400).json({ error: 'Interests must be an array with max 20 items' });
    }
    if (updates.displayName && updates.displayName.length > 100) {
      return res.status(400).json({ error: 'Display name too long (max 100 characters)' });
    }

    updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();
    await setDoc('users', uid, updates);
    const updated = await getDoc('users', uid);

    log.info('Updated user profile', { uid, fields: Object.keys(updates) });
    res.status(200).json(updated);
  } else {
    res.status(405).json({ error: 'Method not allowed' });
  }
}, { auth: true, cacheControl: 'PRIVATE' });
