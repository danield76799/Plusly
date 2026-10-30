package com.danield.plusly.app

import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.provider.ContactsContract
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Leest de contacten uit het telefoonboek van Android en slaat een
 * gedeeld contact op.
 *
 * De Flutter-kant vraagt de toestemming (READ_CONTACTS en
 * WRITE_CONTACTS) via permission_handler en roept daarna `listContacts`
 * of `saveContact` aan.
 */
class ContactsChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.danield.plusly.app/contacts"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "listContacts" -> {
                try {
                    result.success(listContacts())
                } catch (e: Exception) {
                    result.error("contacts_failed", e.message, null)
                }
            }
            "saveContact" -> {
                try {
                    result.success(saveContact(call))
                } catch (e: Exception) {
                    result.error("contact_save_failed", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    /**
     * Leest de contacten met een telefoonnummer uit het telefoonboek.
     *
     * Een contact zonder nummer is niet bruikbaar om te delen, dus die
     * worden overgeslagen.
     */
    private fun listContacts(): List<Map<String, Any?>> {
        val contacten = linkedMapOf<String, MutableMap<String, Any?>>()

        // Eerst de telefoonnummers.
        val telefoonUri = ContactsContract.CommonDataKinds.Phone.CONTENT_URI
        val telefoonProjectie = arrayOf(
            ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
            ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME_PRIMARY,
            ContactsContract.CommonDataKinds.Phone.NUMBER
        )
        context.contentResolver.query(
            telefoonUri,
            telefoonProjectie,
            null,
            null,
            "${ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME_PRIMARY} ASC"
        )?.use { cursor ->
            val idIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CONTACT_ID)
            val nameIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME_PRIMARY)
            val numberIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)
            while (cursor.moveToNext()) {
                val id = cursor.getString(idIndex) ?: continue
                val naam = cursor.getString(nameIndex)?.trim().orEmpty()
                val nummer = cursor.getString(numberIndex)?.trim().orEmpty()
                if (naam.isEmpty() || nummer.isEmpty()) continue
                val contact = contacten.getOrPut(id) {
                    mutableMapOf<String, Any?>(
                        "id" to id,
                        "name" to naam,
                        "phones" to mutableListOf<String>()
                    )
                }
                @Suppress("UNCHECKED_CAST")
                (contact["phones"] as MutableList<String>).add(nummer)
            }
        }

        // Daarna de e-mailadressen, aan dezelfde contacten toevoegen.
        val emailUri = ContactsContract.CommonDataKinds.Email.CONTENT_URI
        val emailProjection = arrayOf(
            ContactsContract.CommonDataKinds.Email.CONTACT_ID,
            ContactsContract.CommonDataKinds.Email.ADDRESS
        )
        context.contentResolver.query(
            emailUri,
            emailProjection,
            null,
            null,
            null
        )?.use { cursor ->
            val idIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.CONTACT_ID)
            val addressIndex = cursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.ADDRESS)
            while (cursor.moveToNext()) {
                val id = cursor.getString(idIndex) ?: continue
                val adres = cursor.getString(addressIndex)?.trim().orEmpty()
                if (adres.isEmpty()) continue
                val contact = contacten[id] ?: continue
                if (!contact.containsKey("emails")) {
                    contact["emails"] = mutableListOf<String>()
                }
                @Suppress("UNCHECKED_CAST")
                (contact["emails"] as MutableList<String>).add(adres)
            }
        }

        return contacten.values.toList()
    }

    /**
     * Bewaart een contact in het telefoonboek.
     *
     * De gegevens komen binnen als een map met display_name, phone en
     * email. De vCard hoeft niet apart te worden opgeslagen: de losse
     * velden zijn genoeg voor een bruikbaar contact.
     */
    private fun saveContact(call: MethodCall): Boolean {
        val naam = (call.argument<String>("display_name") ?: "").trim()
        if (naam.isEmpty()) {
            return false
        }
        val telefoons = call.argument<List<String>>("phone") ?: emptyList()
        val emails = call.argument<List<String>>("email") ?: emptyList()

        // 1. De ruwe contact aanmaken.
        val rawWaarde = ContentValues().apply {
            put(ContactsContract.RawContacts.ACCOUNT_TYPE, null as String?)
            put(ContactsContract.RawContacts.ACCOUNT_NAME, null as String?)
        }
        val rawUri = context.contentResolver.insert(
            ContactsContract.RawContacts.CONTENT_URI,
            rawWaarde
        ) ?: return false
        val rawId = ContentUris.parseId(rawUri)

        // 2. De weergavenaam.
        val naamWaarde = ContentValues().apply {
            put(ContactsContract.Data.RAW_CONTACT_ID, rawId)
            put(
                ContactsContract.Data.MIMETYPE,
                ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE
            )
            put(ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME, naam)
        }
        context.contentResolver.insert(ContactsContract.Data.CONTENT_URI, naamWaarde)

        // 3. De telefoonnummers.
        for (telefoon in telefoons.map { it.trim() }.filter { it.isNotEmpty() }) {
            val waarde = ContentValues().apply {
                put(ContactsContract.Data.RAW_CONTACT_ID, rawId)
                put(
                    ContactsContract.Data.MIMETYPE,
                    ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE
                )
                put(ContactsContract.CommonDataKinds.Phone.NUMBER, telefoon)
                put(
                    ContactsContract.CommonDataKinds.Phone.TYPE,
                    ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE
                )
            }
            context.contentResolver.insert(ContactsContract.Data.CONTENT_URI, waarde)
        }

        // 4. De e-mailadressen.
        for (email in emails.map { it.trim() }.filter { it.isNotEmpty() }) {
            val waarde = ContentValues().apply {
                put(ContactsContract.Data.RAW_CONTACT_ID, rawId)
                put(
                    ContactsContract.Data.MIMETYPE,
                    ContactsContract.CommonDataKinds.Email.CONTENT_ITEM_TYPE
                )
                put(ContactsContract.CommonDataKinds.Email.ADDRESS, email)
                put(
                    ContactsContract.CommonDataKinds.Email.TYPE,
                    ContactsContract.CommonDataKinds.Email.TYPE_HOME
                )
            }
            context.contentResolver.insert(ContactsContract.Data.CONTENT_URI, waarde)
        }

        return true
    }
}
