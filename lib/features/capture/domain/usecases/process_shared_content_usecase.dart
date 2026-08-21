import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../../../../database/daos/shared_content_dao.dart';
import '../../../../platform/share_channel.dart';
import '../../data/datasources/link_reader_data_source.dart';
import '../../data/datasources/ocr_data_source.dart';

class ProcessedShareResult {
  final String sharedContentId;
  final String type;
  final String title;
  final String extractedText;
  final String? imagePath;
  final String? url;

  ProcessedShareResult({
    required this.sharedContentId,
    required this.type,
    required this.title,
    required this.extractedText,
    this.imagePath,
    this.url,
  });
}

class ProcessSharedContentUseCase {
  final SharedContentDao _sharedContentDao;
  final OcrDataSource _ocrDataSource;
  final LinkReaderDataSource _linkReaderDataSource;
  static const _uuid = Uuid();

  ProcessSharedContentUseCase({
    required SharedContentDao sharedContentDao,
    OcrDataSource? ocrDataSource,
    LinkReaderDataSource? linkReaderDataSource,
  })  : _sharedContentDao = sharedContentDao,
        _ocrDataSource = ocrDataSource ?? OcrDataSource(),
        _linkReaderDataSource = linkReaderDataSource ?? LinkReaderDataSource();

  Future<ProcessedShareResult> execute(SharedPayload payload) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final shareId = _uuid.v4();

    String title = 'Shared Content';
    String extractedText = '';
    String? imagePath;
    String? url;

    if (payload.type == 'image' && payload.filePath != null) {
      imagePath = payload.filePath;
      title = 'Shared Image / Screenshot';
      extractedText = await _ocrDataSource.processImage(payload.filePath!);
    } else if (payload.type == 'video' && payload.filePath != null) {
      title = 'Shared Video';
      extractedText = 'Attached video: ${payload.filePath!.split('/').last}';
    } else if (payload.type == 'audio' && payload.filePath != null) {
      title = 'Shared Audio Recording';
      extractedText = 'Attached audio: ${payload.filePath!.split('/').last}';
    } else if (payload.type == 'pdf' && payload.filePath != null) {
      title = 'Shared PDF Document';
      extractedText = 'Attached PDF: ${payload.filePath!.split('/').last}';
    } else if (payload.filePath != null) {
      title = 'Shared File / Document';
      extractedText = 'Attached file: ${payload.filePath!.split('/').last}';
    } else if (payload.type == 'text' && payload.content != null) {
      final textContent = payload.content!;
      if (textContent.startsWith('http://') || textContent.startsWith('https://')) {
        url = textContent;
        final summary = await _linkReaderDataSource.fetchLinkSummary(url);
        title = summary.title;
        extractedText = summary.description;
      } else {
        title = 'Shared Text Note';
        extractedText = textContent;
      }
    }

    await _sharedContentDao.insertSharedContent(
      SharedContentsCompanion(
        id: Value(shareId),
        type: Value(payload.type),
        rawPath: Value(imagePath),
        rawUrl: Value(url),
        ocrText: Value(extractedText),
        pageTitle: Value(title),
        status: const Value('processed'),
        createdAt: Value(nowMs),
        updatedAt: Value(nowMs),
      ),
    );

    return ProcessedShareResult(
      sharedContentId: shareId,
      type: payload.type,
      title: title,
      extractedText: extractedText,
      imagePath: imagePath,
      url: url,
    );
  }
}
