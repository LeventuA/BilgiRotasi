'use strict';

function isCompatibleSubset(report, {
  expectedCurrentCount,
  expectedSubsetCount,
} = {}) {
  if (!report || typeof report !== 'object') return false;
  if (!Number.isInteger(expectedCurrentCount) || expectedCurrentCount < 1) return false;
  if (!Number.isInteger(expectedSubsetCount) || expectedSubsetCount < 0) return false;
  if (expectedSubsetCount > expectedCurrentCount) return false;
  if (Number(report.currentCount) !== expectedCurrentCount) return false;
  if (Number(report.legacyCount) !== expectedSubsetCount) return false;
  if (!Array.isArray(report.missing) || !Array.isArray(report.extra) || !Array.isArray(report.mismatched)) {
    return false;
  }
  return report.missing.length === expectedCurrentCount - expectedSubsetCount
    && report.extra.length === 0
    && report.mismatched.length === 0;
}

module.exports = { isCompatibleSubset };
