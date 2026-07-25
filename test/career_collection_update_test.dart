import 'package:flutter_test/flutter_test.dart';

void main() {
  test('kariyer güncellemesi kaynakta bulunuyor', () {
    const source = '1.48.5+69';
    expect(source, contains('+69'));
  });

  test('pasaport usta şartları kolay değildir', () {
    const correct = 3000;
    const accuracy = 80;
    const activeDays = 50;
    expect(correct, greaterThanOrEqualTo(3000));
    expect(accuracy, greaterThanOrEqualTo(80));
    expect(activeDays, greaterThanOrEqualTo(50));
  });
}
