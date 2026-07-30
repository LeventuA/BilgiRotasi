'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const {
  deterministicMatchId,
  ratingDelta,
  resultForScores,
  retentionCutoffs,
  safeQuestionCount,
  updatedProfile,
} = require('../duel_helpers');

test('match id is idempotent regardless of player order', () => {
  assert.equal(
    deterministicMatchId('ticket-a', 'ticket-b'),
    deterministicMatchId('ticket-b', 'ticket-a'),
  );
});

test('rating is server-calculated and loss is bounded', () => {
  assert.equal(
    ratingDelta({
      playerRating: 1000,
      opponentRating: 1500,
      result: 'win',
      matchesPlayed: 0,
    }),
    20,
  );
  assert.equal(
    ratingDelta({
      playerRating: 1000,
      opponentRating: 1500,
      result: 'loss',
      matchesPlayed: 0,
    }),
    -4,
  );
  assert.equal(
    ratingDelta({
      playerRating: 1000,
      opponentRating: 1000,
      result: 'win',
      matchesPlayed: 8,
    }),
    18,
  );
  assert.equal(
    ratingDelta({
      playerRating: 1200,
      opponentRating: 900,
      result: 'loss',
      matchesPlayed: 8,
    }),
    -8,
  );
});

test('profile update is single deterministic award', () => {
  const profile = updatedProfile(
    { rating: 1000, matchesPlayed: 5 },
    1000,
    'win',
    { opponentName: 'Rakip' },
  );
  assert.equal(profile.rating, 1018);
  assert.equal(profile.matchesPlayed, 6);
  assert.equal(profile.wins, 1);
});

test('score and question count validation is strict', () => {
  assert.equal(resultForScores(8, 7), 'win');
  assert.equal(resultForScores(7, 8), 'loss');
  assert.equal(resultForScores(8, 8), 'draw');
  assert.equal(safeQuestionCount(20), 20);
  assert.throws(() => safeQuestionCount(15));
});

test('retention cutoffs are ordered and explicit', () => {
  const cutoffs = retentionCutoffs(Date.UTC(2026, 6, 30));
  assert.ok(cutoffs.queue > cutoffs.unfinishedMatch);
  assert.ok(cutoffs.unfinishedMatch > cutoffs.completedPersonalData);
  assert.ok(cutoffs.progress > cutoffs.completedPersonalData);
  assert.equal(
    cutoffs.resultClaim.getTime(),
    cutoffs.completedPersonalData.getTime(),
  );
});
