import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as device_contacts;

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

class DeviceContactsRepository implements ContactsRepository {
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
