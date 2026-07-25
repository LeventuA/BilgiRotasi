const SPREADSHEET_ID = '1g2134xqm9k4cyFEDquMS_uC55zLv7Yw2AY20vsVn2G0';
const SHEET_NAME = 'Geri Bildirimler';

function doGet() {
  return jsonResponse({
    ok: true,
    service: 'Bilgi Rotası Soru Geri Bildirimleri'
  });
}

function doPost(e) {
  try {
    const payload = JSON.parse(e.postData.contents || '{}');
    const sheet = SpreadsheetApp
      .openById(SPREADSHEET_ID)
      .getSheetByName(SHEET_NAME);

    if (!sheet) {
      throw new Error('Geri Bildirimler sayfası bulunamadı.');
    }

    const eventId = clean(payload.eventId);

    if (!eventId) {
      throw new Error('Olay ID eksik.');
    }

    const lastRow = sheet.getLastRow();

    if (lastRow >= 2) {
      const found = sheet
        .getRange(2, 23, lastRow - 1, 1)
        .createTextFinder(eventId)
        .matchEntireCell(true)
        .findNext();

      if (found) {
        return jsonResponse({ok: true, duplicate: true});
      }
    }

    const options = Array.isArray(payload.options)
      ? payload.options
      : [];

    sheet.appendRow([
      new Date(),
      'Bekliyor',
      clean(payload.questionId),
      clean(payload.category),
      clean(payload.systemDifficulty),
      clean(payload.userDifficultyVote),
      clean(payload.feedbackType),
      clean(payload.errorReason),
      clean(payload.userNote),
      clean(payload.questionText),
      clean(options[0]),
      clean(options[1]),
      clean(options[2]),
      clean(options[3]),
      clean(payload.correctAnswer),
      clean(payload.userAnswer),
      payload.wasCorrect === true ? 'Evet' : 'Hayır',
      clean(payload.gameMode),
      clean(payload.playerName),
      clean(payload.deviceId),
      clean(payload.appVersion),
      payload.sentFromQueue === true ? 'Evet' : 'Hayır',
      eventId,
      '',
      '',
      'Hayır'
    ]);

    return jsonResponse({ok: true, duplicate: false});
  } catch (error) {
    return jsonResponse({
      ok: false,
      error: String(error && error.message || error)
    });
  }
}

function clean(value) {
  if (value === null || value === undefined) return '';
  return String(value).substring(0, 5000);
}

function jsonResponse(value) {
  return ContentService
    .createTextOutput(JSON.stringify(value))
    .setMimeType(ContentService.MimeType.JSON);
}
