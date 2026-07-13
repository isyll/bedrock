import 'package:bedrock/core/storage/storage_keys.dart';
import 'package:bedrock/services/review/app_review_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryKeyValueStorage storage;
  late FakeStoreService store;
  late DateTime now;

  setUp(() {
    storage = .new();
    store = .new();
    now = .utc(2026, 7, 12);
  });

  AppReviewService buildService() => .new(
    storage: storage,
    store: store,
    clock: () => now,
  );

  Future<void> recordSessions(AppReviewService service, int count) async {
    for (var i = 0; i < count; i++) {
      await service.recordSession();
    }
  }

  test('recordSession counts sessions and stamps the first one', () async {
    final service = buildService();

    await recordSessions(service, 3);

    expect(storage.getInt(StorageKeys.reviewSessionCount), 3);
    expect(
      storage.getString(StorageKeys.reviewFirstSessionAt),
      now.toIso8601String(),
    );
  });

  test('does not prompt before enough sessions', () async {
    final service = buildService();
    await recordSessions(service, 4);
    now = now.add(const .new(days: 10));

    await service.maybeRequestReview();

    expect(store.requestReviewCalls, 0);
  });

  test('does not prompt before the minimum usage period', () async {
    final service = buildService();
    await recordSessions(service, 5);
    now = now.add(const .new(days: 2));

    await service.maybeRequestReview();

    expect(store.requestReviewCalls, 0);
  });

  test('prompts once conditions are met and records the prompt', () async {
    final service = buildService();
    await recordSessions(service, 5);
    now = now.add(const .new(days: 4));

    await service.maybeRequestReview();

    expect(store.requestReviewCalls, 1);
    expect(
      storage.getString(StorageKeys.reviewLastPromptAt),
      now.toIso8601String(),
    );
  });

  test('waits for the interval before prompting again', () async {
    final service = buildService();
    await recordSessions(service, 5);
    now = now.add(const .new(days: 4));
    await service.maybeRequestReview();

    now = now.add(const .new(days: 30));
    await service.maybeRequestReview();
    expect(store.requestReviewCalls, 1);

    now = now.add(const .new(days: 61));
    await service.maybeRequestReview();
    expect(store.requestReviewCalls, 2);
  });

  test('retries later when the store cannot prompt', () async {
    store.reviewAvailable = false;
    final service = buildService();
    await recordSessions(service, 5);
    now = now.add(const .new(days: 4));

    await service.maybeRequestReview();

    expect(store.requestReviewCalls, 1);
    expect(storage.getString(StorageKeys.reviewLastPromptAt), isNull);

    await service.maybeRequestReview();
    expect(store.requestReviewCalls, 2);
  });
}
