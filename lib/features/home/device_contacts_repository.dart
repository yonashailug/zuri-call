import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as device_contacts;

import '../../core/storage/zuri_database.dart';
import 'contact_preview.dart';

enum ContactsLoadStatus { loaded, denied, unavailable }

class ContactsLoadResult {
  const ContactsLoadResult.loaded(this.contacts)
      : status = ContactsLoadStatus.loaded,
        message = null;

  const ContactsLoadResult.denied()
      : status = ContactsLoadStatus.denied,
        contacts = const [],
        message = null;

  const ContactsLoadResult.unavailable(this.message)
      : status = ContactsLoadStatus.unavailable,
        contacts = const [];

  final ContactsLoadStatus status;
  final List<ContactPreview> contacts;
  final String? message;
}

abstract class ContactsRepository {
  Future<ContactsLoadResult> loadContacts();
}

abstract class ContactsDataSource {
  Future<ContactsLoadResult> loadContacts();
}

class DeviceContactsDataSource implements ContactsDataSource {
  @override
  Future<ContactsLoadResult> loadContacts() async {
    try {
      final permissionStatus = await device_contacts.FlutterContacts.permissions
          .request(device_contacts.PermissionType.read);
      if (permissionStatus != device_contacts.PermissionStatus.granted &&
          permissionStatus != device_contacts.PermissionStatus.limited) {
        return const ContactsLoadResult.denied();
      }

      final contacts = await device_contacts.FlutterContacts.getAll(
        properties: const {device_contacts.ContactProperty.phone},
      );

      return ContactsLoadResult.loaded(
        contacts.expand(_contactPhoneNumbers).toList()
          ..sort((a, b) => a.name.compareTo(b.name)),
      );
    } on MissingPluginException {
      return const ContactsLoadResult.unavailable(
        'Contacts are only available on a physical device.',
      );
    } on PlatformException catch (error) {
      return ContactsLoadResult.unavailable(
        error.message ?? 'Could not load contacts.',
      );
    }
  }

  Iterable<ContactPreview> _contactPhoneNumbers(
    device_contacts.Contact contact,
  ) sync* {
    for (final phone in contact.phones) {
      final number = phone.number.trim();
      if (number.isEmpty) continue;

      yield ContactPreview.fromNameAndPhone(
        name: contact.displayName ?? '',
        phone: number,
      );
    }
  }
}

class DeviceContactsRepository implements ContactsRepository {
  DeviceContactsRepository({
    required ZuriDatabase database,
    ContactsDataSource? deviceDataSource,
  })  : _database = database,
        _deviceDataSource = deviceDataSource ?? DeviceContactsDataSource();

  final ZuriDatabase _database;
  final ContactsDataSource _deviceDataSource;

  @override
  Future<ContactsLoadResult> loadContacts() async {
    final result = await _deviceDataSource.loadContacts();

    if (result.status == ContactsLoadStatus.loaded) {
      await _replaceCachedContacts(result.contacts);
      return result;
    }

    if (result.status == ContactsLoadStatus.unavailable) {
      final cachedContacts = await _loadCachedContacts();
      if (cachedContacts.isNotEmpty) {
        return ContactsLoadResult.loaded(cachedContacts);
      }
    }

    return result;
  }

  Future<List<ContactPreview>> _loadCachedContacts() async {
    final rows = await (_database.select(_database.cachedContacts)
          ..orderBy([
            (table) => OrderingTerm(
                  expression: table.name,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();

    return rows
        .map(
          (row) => ContactPreview.fromNameAndPhone(
            name: row.name,
            phone: row.phone,
          ),
        )
        .toList();
  }

  Future<void> _replaceCachedContacts(List<ContactPreview> contacts) async {
    final sortedContacts = [...contacts]
      ..sort((a, b) => a.name.compareTo(b.name));
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      await _database.delete(_database.cachedContacts).go();
      await _database.batch((batch) {
        batch.insertAll(
          _database.cachedContacts,
          sortedContacts.map(
            (contact) => CachedContactsCompanion.insert(
              name: contact.name,
              phone: contact.phone,
              cachedAt: now,
            ),
          ),
        );
      });
    });
  }
}
