'use strict';

const { createHash, randomUUID } = require('node:crypto');

const INITIAL_RATING = 1000;

function clamp(value, minimum, maximum) {
  return Math.max(minimum, Math.min(maximum, value));
}

function ratingDelta({
  playerRating,
  opponentRating,
  result,
  matchesPlayed,
}) {
  if (result === 'draw') return 0;
  const placement = matchesPlayed < 5;
  const difference = opponentRating - playerRating;
  if (placement) {
    return result === 'win' ? 20 : -4;
  }
  let win = 18;
  let loss = -7;
  if (difference >= 150) {
    win = 22;
    loss = -5;
  } else if (difference <= -150) {
    win = 14;
    loss = -8;
  }
  return result === 'win' ? win : loss;
}

function updatedProfile(profile = {}, opponentRating, result, recentMatch) {
  const rating = Math.max(0, Number(profile.rating ?? INITIAL_RATING));
  const matchesPlayed = Math.max(0, Number(profile.matchesPlayed ?? 0));
  const delta = ratingDelta({
    playerRating: rating,
    opponentRating,
    result,
    matchesPlayed,
  });
  const nextRating = Math.max(0, rating + delta);
  const nextStreak =
    result === 'win' ? Number(profile.currentWinStreak ?? 0) + 1 : 0;
  return {
    rating: nextRating,
    matchesPlayed: matchesPlayed + 1,
    wins: Number(profile.wins ?? 0) + (result === 'win' ? 1 : 0),
    losses: Number(profile.losses ?? 0) + (result === 'loss' ? 1 : 0),
    draws: Number(profile.draws ?? 0) + (result === 'draw' ? 1 : 0),
    currentWinStreak: nextStreak,
    bestWinStreak: Math.max(
      Number(profile.bestWinStreak ?? 0),
      nextStreak,
    ),
    highestRating: Math.max(
      Number(profile.highestRating ?? INITIAL_RATING),
      nextRating,
    ),
    ratingPolicyVersion: 2,
    recentMatches: [
      { ...recentMatch, ratingDelta: delta },
      ...(Array.isArray(profile.recentMatches) ? profile.recentMatches : []),
    ].slice(0, 10),
  };
}

function deterministicMatchId(firstTicket, secondTicket) {
  const pair = [String(firstTicket), String(secondTicket)].sort().join(':');
  return createHash('sha256').update(pair).digest('hex').slice(0, 32);
}

function newPublicPlayerId() {
  return `p_${randomUUID().replaceAll('-', '')}`;
}

function safeQuestionCount(value) {
  const count = Number(value);
  if (![10, 20, 30].includes(count)) {
    throw new Error('unsupported-question-count');
  }
  return count;
}

function resultForScores(ownScore, opponentScore) {
  if (ownScore === opponentScore) return 'draw';
  return ownScore > opponentScore ? 'win' : 'loss';
}

function retentionCutoffs(now = Date.now()) {
  const day = 24 * 60 * 60 * 1000;
  return {
    queue: new Date(now - 10 * 60 * 1000),
    unfinishedMatch: new Date(now - day),
    completedPersonalData: new Date(now - 90 * day),
    progress: new Date(now - 30 * day),
    resultClaim: new Date(now - 90 * day),
    reportReview: new Date(now - 365 * day),
  };
}

module.exports = {
  INITIAL_RATING,
  deterministicMatchId,
  newPublicPlayerId,
  ratingDelta,
  resultForScores,
  retentionCutoffs,
  safeQuestionCount,
  updatedProfile,
};
