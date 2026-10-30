import 'package:flutter/material.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/contacts_service.dart';

/// WhatsApp-achtige contactkiezer: zoek in je eigen telefoonboek en
/// kies wie je wilt delen.
///
/// Geeft de gekozen contact terug via [Navigator.pop], of null als
/// niets gekozen is.
class ContactPickerScreen extends StatefulWidget {
  const ContactPickerScreen({super.key});

  @override
  State<ContactPickerScreen> createState() => _ContactPickerScreenState();
}

class _ContactPickerScreenState extends State<ContactPickerScreen> {
  List<DeviceContact> _contacten = const [];
  bool _bezig = true;
  String _zoekterm = '';

  @override
  void initState() {
    super.initState();
    _laad();
  }

  Future<void> _laad() async {
    final contacten = await ContactsService.loadContacts();
    if (!mounted) return;
    setState(() {
      _contacten = contacten;
      _bezig = false;
    });
  }

  List<DeviceContact> get _gefilterd {
    if (_zoekterm.trim().isEmpty) return _contacten;
    final term = _zoekterm.trim().toLowerCase();
    return _contacten.where((c) {
      if (c.name.toLowerCase().contains(term)) return true;
      return c.phones.any((p) => p.toLowerCase().contains(term));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final contacten = _gefilterd;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendContact),
        leading: const CloseButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: false,
              onChanged: (v) => setState(() => _zoekterm = v),
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: _bezig
                ? const Center(child: CircularProgressIndicator())
                : contacten.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.contactsEmpty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: contacten.length,
                    itemBuilder: (context, index) {
                      final contact = contacten[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            contact.name.isNotEmpty
                                ? contact.name.characters.first.toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(contact.name),
                        subtitle: contact.primaryPhone != null
                            ? Text(contact.primaryPhone!)
                            : null,
                        onTap: () => Navigator.of(context).pop(contact),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
