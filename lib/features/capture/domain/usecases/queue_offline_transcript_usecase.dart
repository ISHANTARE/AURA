import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../database/app_database.dart';

class QueueOfflineTranscriptUseCase {
  final AppDatabase _db;
  static const Uuid _uuid = Uuid();

  QueueOfflineTranscriptUseCase(this._db);

  Future<String> execute(String transcript) async {
    final queueId = _uuid.v4();
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;

    await _db.into(_db.offlineQueues).insert(
      OfflineQueuesCompanion.insert(
        id: queueId,
        content: transcript,
        status: const Value('pending'),
        createdAt: nowEpoch,
      ),
    );

    return queueId;
  }
}
