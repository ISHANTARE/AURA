import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/database/app_database.dart';
import 'package:aura/features/home/domain/usecases/generate_morning_briefing_usecase.dart';

void main() {
  late AppDatabase db;
  late ItemDao itemDao;
  late GenerateMorningBriefingUseCase useCase;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    itemDao = ItemDao(db);
    useCase = GenerateMorningBriefingUseCase(itemDao: itemDao);
  });

  tearDown(() async {
    await db.close();
  });

  group('GenerateMorningBriefingUseCase Unit Tests', () {
    test('Generates briefing data with correct user greeting', () async {
      final briefing = await useCase.execute();

      expect(briefing.greeting, contains('Ishant'));
      expect(briefing.greeting, isNot(contains('Ishan.')));
      expect(briefing.dateFormatted, isNotEmpty);
      expect(briefing.summaryLine, isNotEmpty);
    });
  });
}
