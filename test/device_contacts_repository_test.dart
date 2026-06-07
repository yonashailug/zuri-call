import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zuri_call/core/storage/zuri_database.dart';
import 'package:zuri_call/features/home/contact_preview.dart';
import 'package:zuri_call/features/home/device_contacts_repository.dart';

void main() {
  late ZuriDatabase database;

  setUp(() {
    database = ZuriDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('caches contacts from successful device load', () async {
    final repository = DeviceContactsRepository(
      database: database,
      deviceDataSource: _FakeContactsDataSource(
        ContactsLoadResult.loaded([
          ContactPreview.fromNameAndPhone(
            name: 'Jordan Rivera',
            phone: '+1 (503) 555-0278',
          ),
          ContactPreview.fromNameAndPhone(
            name: 'Maya Kim',
            phone: '+1 (206) 555-0142',
          ),
        ]),
      ),
    );

    final result = await repository.loadContacts();
    final cachedRows = await database.select(database.cachedContacts).get();

    expect(result.status, ContactsLoadStatus.loaded);
    expect(result.contacts.map((contact) => contact.name), [
      'Jordan Rivera',
      'Maya Kim',
    ]);
    expect(cachedRows.map((row) => row.name), [
      'Jordan Rivera',
      'Maya Kim',
    ]);
  });

  test('falls back to cached contacts when device contacts are unavailable',
      () async {
    final freshRepository = DeviceContactsRepository(
      database: database,
      deviceDataSource: _FakeContactsDataSource(
        ContactsLoadResult.loaded([
          ContactPreview.fromNameAndPhone(
            name: 'Maya Kim',
            phone: '+1 (206) 555-0142',
          ),
        ]),
      ),
    );
    await freshRepository.loadContacts();

    final fallbackRepository = DeviceContactsRepository(
      database: database,
      deviceDataSource: const _FakeContactsDataSource(
        ContactsLoadResult.unavailable('Device unavailable.'),
      ),
    );

    final result = await fallbackRepository.loadContacts();

    expect(result.status, ContactsLoadStatus.loaded);
    expect(result.message, isNull);
    expect(result.contacts.single.name, 'Maya Kim');
  });

  test('returns unavailable when device and cache are unavailable', () async {
    final repository = DeviceContactsRepository(
      database: database,
      deviceDataSource: const _FakeContactsDataSource(
        ContactsLoadResult.unavailable('Device unavailable.'),
      ),
    );

    final result = await repository.loadContacts();

    expect(result.status, ContactsLoadStatus.unavailable);
    expect(result.contacts, isEmpty);
    expect(result.message, 'Device unavailable.');
  });

  test('does not replace cache when permission is denied', () async {
    final freshRepository = DeviceContactsRepository(
      database: database,
      deviceDataSource: _FakeContactsDataSource(
        ContactsLoadResult.loaded([
          ContactPreview.fromNameAndPhone(
            name: 'Maya Kim',
            phone: '+1 (206) 555-0142',
          ),
        ]),
      ),
    );
    await freshRepository.loadContacts();

    final deniedRepository = DeviceContactsRepository(
      database: database,
      deviceDataSource: const _FakeContactsDataSource(
        ContactsLoadResult.denied(),
      ),
    );

    final result = await deniedRepository.loadContacts();
    final cachedRows = await database.select(database.cachedContacts).get();

    expect(result.status, ContactsLoadStatus.denied);
    expect(result.contacts, isEmpty);
    expect(cachedRows.single.name, 'Maya Kim');
  });
}

class _FakeContactsDataSource implements ContactsDataSource {
  const _FakeContactsDataSource(this.result);

  final ContactsLoadResult result;

  @override
  Future<ContactsLoadResult> loadContacts() async {
    return result;
  }
}
