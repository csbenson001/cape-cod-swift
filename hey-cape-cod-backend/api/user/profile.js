const { verifyAuth } = require('../../lib/auth-middleware');
const { getDoc, setDoc } = require('../../lib/firestore');
const { admin } = require('../../lib/firebase-admin');

module.exports = async function handler(req, res) {
  const uid = await verifyAuth(req, res);
  if (!uid) return;

  if (req.method === 'GET') {
    return handleGet(req, res, uid);
  } else if (req.method === 'PUT') {
    return handlePut(req, res, uid);
  } else {
    return res.status(405).json({ error: 'Method not allowed' });
  }
};

async function handleGet(req, res, uid) {
  try {
    let user = await getDoc('users', uid);

    if (!user) {
      // Auto-create profile for new users
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
    }

    res.status(200).json(user);
  } catch (err) {
    console.error('[api/user/profile] GET error:', err);
    res.status(500).json({ error: 'Failed to fetch profile' });
  }
}

async function handlePut(req, res, uid) {
  try {
    const allowedFields = [
      'displayName', 'currentMode', 'visitType', 'interests',
      'favoritePoiIds',
    ];

    const updates = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    }

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({ error: 'No valid fields to update' });
    }

    updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();

    await setDoc('users', uid, updates);
    const updated = await getDoc('users', uid);
    res.status(200).json(updated);
  } catch (err) {
    console.error('[api/user/profile] PUT error:', err);
    res.status(500).json({ error: 'Failed to update profile' });
  }
}
