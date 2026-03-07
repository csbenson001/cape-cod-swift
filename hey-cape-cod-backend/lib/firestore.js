const { db } = require('./firebase-admin');

/**
 * Get a single document by collection and ID.
 */
async function getDoc(collection, id) {
  const doc = await db.collection(collection).doc(id).get();
  if (!doc.exists) return null;
  return { id: doc.id, ...doc.data() };
}

/**
 * Query documents from a collection with optional filters.
 * @param {string} collection
 * @param {Array<{field: string, op: string, value: any}>} filters
 * @param {Object} options - { limit, offset, orderBy, orderDir }
 */
async function queryDocs(collection, filters = [], options = {}) {
  let query = db.collection(collection);

  for (const f of filters) {
    query = query.where(f.field, f.op, f.value);
  }

  if (options.orderBy) {
    query = query.orderBy(options.orderBy, options.orderDir || 'asc');
  }

  if (options.offset) {
    query = query.offset(options.offset);
  }

  if (options.limit) {
    query = query.limit(options.limit);
  }

  const snapshot = await query.get();
  return snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
}

/**
 * Set a document (merge by default).
 */
async function setDoc(collection, id, data, merge = true) {
  await db.collection(collection).doc(id).set(data, { merge });
}

/**
 * Update specific fields on a document.
 */
async function updateDoc(collection, id, data) {
  await db.collection(collection).doc(id).update(data);
}

/**
 * Batch write multiple documents.
 */
async function batchSet(collection, docs) {
  const batch = db.batch();
  for (const doc of docs) {
    const ref = db.collection(collection).doc(doc.id);
    batch.set(ref, doc, { merge: true });
  }
  await batch.commit();
}

module.exports = { getDoc, queryDocs, setDoc, updateDoc, batchSet, db };
