import 'package:flutter_test/flutter_test.dart';
import 'package:rivertide/core/format/text_fold.dart';

void main() {
  test('strips every Vietnamese diacritic and đ', () {
    expect(TextFold.fold('Cần Thơ'), 'can tho');
    expect(TextFold.fold('ĐÀ NẴNG'), 'da nang');
    expect(TextFold.fold('Quy Nhơn'), 'quy nhon');
    expect(TextFold.fold('Rạch Giá  —  Kiên Giang'), 'rach gia — kien giang');
    expect(
      TextFold.fold('àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'),
      '${'a' * 17}${'e' * 11}${'i' * 5}${'o' * 17}${'u' * 11}${'y' * 5}d',
    );
  });

  test('matches accent-insensitive, all words, any order (AC-MAP04-1)', () {
    expect(TextFold.matches('Tân Châu', 'tan chau'), isTrue);
    expect(TextFold.matches('Vũng Tàu Bà Rịa', 'vung tau'), isTrue);
    expect(TextFold.matches('Vũng Tàu', 'TAU vung'), isTrue);
    expect(TextFold.matches('Vũng Tàu', 'vung tao'), isFalse);
    expect(TextFold.matches('Vũng Tàu', '   '), isFalse);
  });
}
