'use strict';

function normalizedQuestionIds(values) {
  if (!Array.isArray(values)) return [];
  return values
    .map((value) => String(value ?? '').trim())
    .filter(Boolean);
}

function invalidQuestionIds(questionIds, playableIds) {
  const allowed = playableIds instanceof Set ? playableIds : new Set(playableIds ?? []);
  return [...new Set(
    normalizedQuestionIds(questionIds).filter((id) => !allowed.has(id)),
  )].sort();
}

function invalidMatchCancellationPatch(ids, timestamp) {
  const invalidIds = [...new Set(normalizedQuestionIds(ids))].sort();
  if (invalidIds.length === 0) {
    throw new Error('invalid-question-id-required');
  }
  return {
    status: 'cancelled',
    resultProcessed: true,
    resultVersion: 2,
    completionType: 'invalid-question',
    cancellationReason: 'question-catalog-mismatch',
    invalidQuestionIds: invalidIds,
    processedBy: 'server-catalog-repair',
    cancelledAt: timestamp,
    completedAt: timestamp,
    updatedAt: timestamp,
  };
}

module.exports = {
  invalidMatchCancellationPatch,
  invalidQuestionIds,
  normalizedQuestionIds,
};
