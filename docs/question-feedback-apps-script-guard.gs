/**
 * Bilgi Rotası soru geri bildirimi — Apps Script tekilleştirme yardımcısı.
 *
 * Mevcut doPost(e) içindeki sheet.appendRow(rowValues) çağrısı yerine:
 *
 * return appendQuestionFeedbackSafely_(sheet, rowValues, payload);
 *
 * kullanılmalıdır. Bu dosya tek başına otomatik deploy edilmez.
 */

const MIN_ACCEPTED_FEEDBACK_VERSION_ = '1.68.11';
const EVENT_ID_COLUMN_ = 23; // W
const MAX_EVENT_ID_LENGTH_ = 180;

function appendQuestionFeedbackSafely_(sheet, rowValues, payload) {
  const version = String(
    payload.appVersion ||
    payload.app_version ||
    payload.version ||
    ''
  ).trim();

  const eventId = String(
    payload.eventId ||
    payload.event_id ||
    payload.olayId ||
    ''
  ).trim();

  if (!eventId || eventId.length > MAX_EVENT_ID_LENGTH_) {
    return feedbackJsonResponse_({
      ok: false,
      accepted: false,
      reason: 'missing_or_invalid_event_id'
    });
  }

  if (compareSemanticVersion_(version, MIN_ACCEPTED_FEEDBACK_VERSION_) < 0) {
    return feedbackJsonResponse_({
      ok: true,
      accepted: false,
      reason: 'old_app_version',
      minimumVersion: MIN_ACCEPTED_FEEDBACK_VERSION_
    });
  }

  if (!Array.isArray(rowValues) || rowValues.length !== 23) {
    return feedbackJsonResponse_({
      ok: false,
      accepted: false,
      reason: 'invalid_row_shape'
    });
  }

  const lock = LockService.getScriptLock();
  if (!lock.tryLock(10000)) {
    return feedbackJsonResponse_({
      ok: false,
      accepted: false,
      retryable: true,
      reason: 'lock_timeout'
    });
  }

  try {
    const lastRow = sheet.getLastRow();
    if (lastRow >= 2) {
      const existing = sheet
        .getRange(2, EVENT_ID_COLUMN_, lastRow - 1, 1)
        .getDisplayValues()
        .flat();

      if (existing.indexOf(eventId) !== -1) {
        return feedbackJsonResponse_({
          ok: true,
          accepted: false,
          duplicate: true,
          reason: 'duplicate_event_id'
        });
      }
    }

    sheet.appendRow(rowValues);
    return feedbackJsonResponse_({
      ok: true,
      accepted: true,
      eventId: eventId
    });
  } finally {
    lock.releaseLock();
  }
}

function compareSemanticVersion_(left, right) {
  const parse = function (value) {
    return String(value || '')
      .split('+')[0]
      .split('.')
      .map(function (part) {
        const match = String(part).match(/\d+/);
        return match ? Number(match[0]) : 0;
      });
  };

  const a = parse(left);
  const b = parse(right);
  const length = Math.max(a.length, b.length, 3);

  for (let i = 0; i < length; i++) {
    const av = a[i] || 0;
    const bv = b[i] || 0;
    if (av < bv) return -1;
    if (av > bv) return 1;
  }
  return 0;
}

function feedbackJsonResponse_(body) {
  return ContentService
    .createTextOutput(JSON.stringify(body))
    .setMimeType(ContentService.MimeType.JSON);
}
