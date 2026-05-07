import 'package:flutter_test/flutter_test.dart';
import 'package:spendo/core/services/receipt_scanner_service.dart';

void main() {
  group('ReceiptScannerService.parseText', () {
    test('prefers final payable total over item totals, VAT, and savings', () {
      const String rawText = '''
ООО "ДВ НЕВАДА"
КАССОВЫЙ ЧЕК 270
1 Фарш из говядины 880.0*0.424 =373.12
2 Смесь Ариба/соус Чи 289.9*1 =289.99
28 Финики сушеные с кос 109.9*1 =109.99
ИТОГО К ОПЛАТЕ =4323.95
БЕЗНАЛИЧНЫМИ =4323.95
СУММА НДС 20% =323.33
СУММА НДС 10% =216.73
ВАША ЭКОНОМИЯ СЕГОДНЯ:
339.62 РУБ.
27.04.25 21:22
ФН 7380440700244561
Самбери 26
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.totalAmount, 4323.95);
      expect(result.amount, 4323.95);
      expect(result.date, DateTime(2025, 4, 27));
      expect(result.suggestedCategoryKey, 'food');
      expect(result.rawText, rawText);
      expect(result.items, hasLength(3));
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          isNot(contains(4323.95)));
      expect(result.items[0].name, contains('Фарш'));
      expect(result.items[0].amount, 373.12);
      expect(result.items[0].suggestedCategoryKey, 'food');
      expect(result.items[0].sourceLine, contains('Фарш'));
    });

    test('returns no amount for a cropped receipt middle without final total',
        () {
      const String rawText = '''
шт. Пакет Майка большой *1000
8.90 *1
=8.90
шт.[M+]4356 Напиток энергетический Флэш
69.90 *1
=69.90
Сумма скидки на позицию: 11.00
шт.[M+]2055 Напиток безалкогольный Флэш
119.90*1
=119.90
Сумма скидки на позицию: 10.00
шт. Водка Граф Ледофф 0,5л Лимон особая
440.90*1
=440.90
Сумма скидки на позицию: 37.00
шт. Напиток винный Вайн 0.75л гранатовое
954.90*1
=954.90
кг Петрушка вес Казахстан
699.90*0.084
=58.79
кг Кинза вес Казахстан
699.90*0.084
=58.79
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.totalAmount, isNull);
      expect(result.amount, isNull);
      expect(result.date, isNull);
      expect(result.suggestedCategoryKey, 'food');
      expect(result.items.length, greaterThanOrEqualTo(5));
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          containsAll(<double>[8.90, 69.90, 119.90, 440.90]));
    });

    test('tolerates mixed Latin and Cyrillic OCR in total context', () {
      const String rawText = '''
OOO "ДB HEBAДA"
1 Чипсы Лейз 179.99*1 =179.99
24 Яйцо куриное C.1 10ш 119.99*1 =119.99
25 Пакет-майка Caмбери 7.99*1 =7.99
ИT0ГO K OПЛATE =2357,51
БEЗHAЛИЧHЫMИ =2357.51
CУMMA HДC 20% =242.17
CУMMA HДC 10% =82.26
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.amount, 2357.51);
      expect(result.date, isNull);
      expect(result.suggestedCategoryKey, 'food');
    });

    test('extracts an English receipt total without picking item prices', () {
      const String rawText = '''
GREEN MARKET
APPLES 2.50
MILK 3.49
SUBTOTAL 5.99
TAX 0.48
TOTAL =6.47
PAID CARD =6.47
05/06/25 18:42
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.totalAmount, 6.47);
      expect(result.totalAmount, isNot(3.49));
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          isNot(contains(6.47)));
    });

    test('prefers bottom payable total over repeated grocery item prices', () {
      const String rawText = '''
OOO "ДВ НЕВАДА"
КАССОВЫЙ ЧЕК 329
1 0505367 шт. Чипсы Лейз 140г сме 179.99*1 =179.99
2 0054820 кг Лимон Аргентина 299.99*0.24 =72.00
3 0589075 шт. Губки д/посуды 6.5х 39.99*1 =39.99
4 0554917 шт.[M+]7002 Напиток эне 84.99*1 =84.99
5 0008053 кг Перец красный КНР 199.99*0.18 =36.00
8 0583670 шт. Сгущенка Главпродук 99.99*1 =99.99
12 0530412 шт. Хумус классический 39.99*1 =39.99
18 0530413 шт. Хумус острый с папр 39.99*1 =39.99
20 0367199 шт.[M+]6284 Напиток мед 119.99*1 =119.99
21 0367199 шт.[M+]2264 Напиток мед 119.99*1 =119.99
22 0367199 шт.[M+]2855 Напиток мед 119.99*1 =119.99
23 0441093 шт. Кукуруза всегда доб 59.99*1 =58.99
24 0344106 шт. Яйцо куриное C.1 10ш 119.99*1 =119.98
25 0278260 шт. Пакет-майка Самбери 7.99*1 =7.99
ИТОГО К ОПЛАТЕ =2357.51
БЕЗНАЛИЧНЫМИ =2357.51
СУММА НДС 20% =242.17
СУММА НДС 10% =82.26
27.04.25 21:22
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.totalAmount, 2357.51);
      expect(result.amount, 2357.51);
      expect(result.amount, isNot(39.99));
      expect(result.date, DateTime(2025, 4, 27));
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          isNot(contains(2357.51)));
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          isNot(contains(242.17)));
    });

    test('does not return a tiny integer when decimal totals are present', () {
      const String rawText = '''
OOO "ДB HEBAДA"
КАССОВЫЙ ЧЕК 3
1 Чипсы Лейз 179.99*1 =179.99
24 Яйцо куриное C.1 10ш 119.99*1 =119.99
25 Пакет-майка Caмбери 7.99*1 =7.99
ИT0ГO K OПЛATE
3
=2357,51
БEЗHAЛИЧHЫMИ =2357.51
CУMMA HДC 20% =242.17
CУMMA HДC 10% =82.26
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.totalAmount, 2357.51);
      expect(result.amount, 2357.51);
      expect(result.amount, isNot(3));
    });

    test('returns null instead of an integer-only total guess', () {
      const String rawText = '''
ООО "Тест"
КАССОВЫЙ ЧЕК 25
ИТОГО К ОПЛАТЕ 3
ФН 7380440700244561
ФД 329
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.amount, isNull);
    });

    test('supports common Russian receipt date formats', () {
      final Map<String, DateTime> samples = <String, DateTime>{
        'дата 27.04.2025 итог к оплате 10.00': DateTime(2025, 4, 27),
        'дата 27.04. 25 итог к оплате 10.00': DateTime(2025, 4, 27),
        'дата 27 . 04 . 25 итог к оплате 10.00': DateTime(2025, 4, 27),
        'дата 27/04/25 итог к оплате 10.00': DateTime(2025, 4, 27),
        'дата 27-04-2025 итог к оплате 10.00': DateTime(2025, 4, 27),
        'дата 2025-04-27 итог к оплате 10.00': DateTime(2025, 4, 27),
        'дата 2025/04/27 итог к оплате 10.00': DateTime(2025, 4, 27),
      };

      for (final MapEntry<String, DateTime> sample in samples.entries) {
        final ReceiptScanResult result =
            ReceiptScannerService.parseText(sample.key);

        expect(result.date, sample.value);
      }
    });

    test('ignores impossible dates', () {
      final ReceiptScanResult result = ReceiptScannerService.parseText(
        'дата 32.13.25 итог к оплате 99.90',
      );

      expect(result.date, isNull);
      expect(result.amount, 99.90);
    });

    test('extracts item drafts from barcode, split, and plain price lines', () {
      const String rawText = '''
ООО "Тест"
1 4607000000000 Молоко Простоквашино 2,5%
89.99*1
=89.99
2 [M+]2055 Хлеб Дарницкий
52,50
СУММА НДС 10% =12.95
СКИДКА =5.00
ИТОГО К ОПЛАТЕ =142,49
ФН 7380440700244561
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.amount, 142.49);
      expect(result.items, hasLength(2));
      expect(result.items[0].name, 'Молоко Простоквашино 2,5%');
      expect(result.items[0].amount, 89.99);
      expect(result.items[0].suggestedCategoryKey, 'food');
      expect(result.items[1].name, 'Хлеб Дарницкий');
      expect(result.items[1].amount, 52.50);
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          isNot(contains(142.49)));
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          isNot(contains(12.95)));
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          isNot(contains(5.00)));
    });

    test('computes item amount only for a clear unit price and quantity', () {
      const String rawText = '''
ООО "Тест"
1 кг Бананы весовые 219.90*0.832
2 шт Хлеб 44.50*2
ИТОГО К ОПЛАТЕ =272.95
БЕЗНАЛИЧНЫМИ =272.95
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.totalAmount, 272.95);
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          containsAll(<double>[182.96, 89.00]));
    });

    test('does not compute item totals from implausible noisy quantities', () {
      const String rawText = '''
ООО "Тест"
1 0554917 шт. Напиток энер 84.99*1 =84.99
2 099024 шт. Шумная OCR строка 99.99*9.903 фрагмент
3 0530412 шт. Хумус классический 39.99*1 =39.99
ИТОГО К ОПЛАТЕ =124.98
БЕЗНАЛИЧНЫМИ =124.98
''';

      final ReceiptScanResult result = ReceiptScannerService.parseText(rawText);

      expect(result.amount, 124.98);
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          isNot(contains(990.24)));
      expect(
        result.items
            .any((ReceiptItemDraft item) => item.name.contains('Шумная')),
        isFalse,
      );
      expect(result.items.map((ReceiptItemDraft item) => item.amount),
          containsAll(<double>[84.99, 39.99]));
    });
  });
}
