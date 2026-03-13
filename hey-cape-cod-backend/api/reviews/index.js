const { withMiddleware } = require('../../lib/middleware');
const { getDoc, queryDocs, setDoc, updateDoc, db } = require('../../lib/firestore');
const { admin } = require('../../lib/firebase-admin');
const { incrementMetric } = require('../../lib/metrics');

const VALID_TARGET_TYPES = ['poi', 'restaurant'];
const VALID_SORT_OPTIONS = ['recent', 'rating', 'helpful'];
const MAX_LIMIT = 100;
const DEFAULT_LIMIT = 50;
const MAX_TAGS = 10;
const MAX_TITLE_LENGTH = 200;
const MAX_BODY_LENGTH = 5000;

module.exports = withMiddleware(async (req, res, log) => {
  if (req.method === 'GET') {
    return handleGet(req, res, log);
  }

  if (req.method === 'POST') {
    return handlePost(req, res, log);
  }
}, { optionalAuth: true, methods: ['GET', 'POST'], cacheControl: 'NONE' });

async function handleGet(req, res, log) {
  const { targetId, targetType, sort = 'recent' } = req.query;
  const limit = Math.min(parseInt(req.query.limit, 10) || DEFAULT_LIMIT, MAX_LIMIT);
  const offset = Math.max(parseInt(req.query.offset, 10) || 0, 0);

  if (!targetId || typeof targetId !== 'string') {
    return res.status(400).json({ error: 'targetId is required' });
  }

  if (!targetType || !VALID_TARGET_TYPES.includes(targetType)) {
    return res.status(400).json({ error: `targetType must be one of: ${VALID_TARGET_TYPES.join(', ')}` });
  }

  if (!VALID_SORT_OPTIONS.includes(sort)) {
    return res.status(400).json({ error: `sort must be one of: ${VALID_SORT_OPTIONS.join(', ')}` });
  }

  const sortConfig = {
    recent: { orderBy: 'createdAt', orderDir: 'desc' },
    rating: { orderBy: 'rating', orderDir: 'desc' },
    helpful: { orderBy: 'helpfulCount', orderDir: 'desc' },
  };

  const filters = [
    { field: 'targetId', op: '==', value: targetId },
    { field: 'targetType', op: '==', value: targetType },
  ];

  const { orderBy, orderDir } = sortConfig[sort];

  // Fetch all matching reviews for aggregation
  const allReviews = await queryDocs('reviews', filters, {
    orderBy,
    orderDir,
  });

  // Compute aggregation
  const total = allReviews.length;
  const distribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
  const tagCounts = {};
  let ratingSum = 0;

  for (const review of allReviews) {
    ratingSum += review.rating;
    distribution[review.rating] = (distribution[review.rating] || 0) + 1;
    if (Array.isArray(review.tags)) {
      for (const tag of review.tags) {
        tagCounts[tag] = (tagCounts[tag] || 0) + 1;
      }
    }
  }

  const averageRating = total > 0 ? Math.round((ratingSum / total) * 10) / 10 : 0;

  const topTags = Object.entries(tagCounts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 10)
    .map(([tag, count]) => ({ tag, count }));

  // Paginate
  const reviews = allReviews.slice(offset, offset + limit);

  log.info('Reviews fetched', { targetId, targetType, count: reviews.length, total });

  res.status(200).json({
    reviews,
    aggregation: {
      averageRating,
      totalReviews: total,
      distribution,
      topTags,
    },
    count: reviews.length,
    total,
  });
}

async function handlePost(req, res, log) {
  const uid = req.uid;
  if (!uid) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  const { action } = req.body;

  if (action === 'helpful') {
    return handleHelpful(req, res, log, uid);
  }

  if (action === 'menu-ratings') {
    return handleMenuRatings(req, res, log, uid);
  }

  return handleCreateReview(req, res, log, uid);
}

async function handleCreateReview(req, res, log, uid) {
  const { targetId, targetType, rating, title, body, tags } = req.body;

  // Validate targetId
  if (!targetId || typeof targetId !== 'string') {
    return res.status(400).json({ error: 'targetId is required' });
  }

  // Validate targetType
  if (!targetType || !VALID_TARGET_TYPES.includes(targetType)) {
    return res.status(400).json({ error: `targetType must be one of: ${VALID_TARGET_TYPES.join(', ')}` });
  }

  // Validate rating
  const numRating = parseInt(rating, 10);
  if (!rating || isNaN(numRating) || numRating < 1 || numRating > 5) {
    return res.status(400).json({ error: 'rating must be an integer between 1 and 5' });
  }

  // Validate optional title
  if (title !== undefined && title !== null) {
    if (typeof title !== 'string' || title.length > MAX_TITLE_LENGTH) {
      return res.status(400).json({ error: `title must be a string of max ${MAX_TITLE_LENGTH} characters` });
    }
  }

  // Validate optional body
  if (body !== undefined && body !== null) {
    if (typeof body !== 'string' || body.length > MAX_BODY_LENGTH) {
      return res.status(400).json({ error: `body must be a string of max ${MAX_BODY_LENGTH} characters` });
    }
  }

  // Validate tags
  if (tags !== undefined && tags !== null) {
    if (!Array.isArray(tags) || tags.length > MAX_TAGS || !tags.every((t) => typeof t === 'string')) {
      return res.status(400).json({ error: `tags must be an array of up to ${MAX_TAGS} strings` });
    }
  }

  const reviewId = db.collection('reviews').doc().id;

  const reviewDoc = {
    id: reviewId,
    uid,
    targetId,
    targetType,
    rating: numRating,
    title: title || null,
    body: body || null,
    tags: tags || [],
    helpfulCount: 0,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  await setDoc('reviews', reviewId, reviewDoc, false);

  incrementMetric('reviewsCreated').catch(() => {});

  log.info('Review created', { reviewId, targetId, targetType, rating: numRating, uid });

  res.status(201).json({ success: true, id: reviewId });
}

async function handleHelpful(req, res, log, uid) {
  const { reviewId } = req.body;

  if (!reviewId || typeof reviewId !== 'string') {
    return res.status(400).json({ error: 'reviewId is required' });
  }

  const review = await getDoc('reviews', reviewId);
  if (!review) {
    return res.status(404).json({ error: 'Review not found' });
  }

  await updateDoc('reviews', reviewId, {
    helpfulCount: admin.firestore.FieldValue.increment(1),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  log.info('Review marked helpful', { reviewId, uid });

  res.status(200).json({ success: true, id: reviewId });
}

async function handleMenuRatings(req, res, log, uid) {
  const { restaurantId, ratings } = req.body;

  if (!restaurantId || typeof restaurantId !== 'string') {
    return res.status(400).json({ error: 'restaurantId is required' });
  }

  if (!Array.isArray(ratings) || ratings.length === 0) {
    return res.status(400).json({ error: 'ratings must be a non-empty array' });
  }

  for (const item of ratings) {
    if (!item.menuItemId || typeof item.menuItemId !== 'string') {
      return res.status(400).json({ error: 'Each rating must have a menuItemId string' });
    }
    const r = parseInt(item.rating, 10);
    if (isNaN(r) || r < 1 || r > 5) {
      return res.status(400).json({ error: 'Each rating must have a rating between 1 and 5' });
    }
  }

  const docId = `${uid}_${restaurantId}_${Date.now()}`;

  await setDoc('menu_ratings', docId, {
    uid,
    restaurantId,
    ratings: ratings.map((r) => ({
      menuItemId: r.menuItemId,
      rating: parseInt(r.rating, 10),
    })),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  }, false);

  log.info('Menu ratings submitted', { restaurantId, count: ratings.length, uid });

  res.status(200).json({ success: true });
}
