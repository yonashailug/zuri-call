/// Resolves a +E.164 phone number to an ISO 3166-1 alpha-2 country code,
/// from which both the emoji flag and 2-letter label are derived.
///
/// Usage:
///   PhoneCountryLookup.flagFor('+251912345678') // → '🇪🇹'
///   PhoneCountryLookup.codeFor('+447911123456') // → 'GB'
library phone_country_lookup;

class PhoneCountryLookup {
  PhoneCountryLookup._();

  /// Returns the emoji flag for a phone number, or null if unrecognised.
  static String? flagFor(String phone) {
    final iso = codeFor(phone);
    return iso != null ? _flagFromIso(iso) : null;
  }

  /// Returns the ISO 3166-1 alpha-2 code for a phone number, or null if unrecognised.
  static String? codeFor(String phone) {
    final normalized = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!normalized.startsWith('+')) return null;

    // Try longest prefix first (up to 5 digits incl. the '+')
    for (final entry in _sortedEntries) {
      if (normalized.startsWith(entry.$1)) return entry.$2;
    }
    return null;
  }

  // ── Internal ─────────────────────────────────────────────────────────────

  static String _flagFromIso(String isoCode) {
    // Unicode regional indicator letters: 🇦 = U+1F1E6, offset by char - 'A'
    return isoCode.toUpperCase().split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) - 0x41 + 0x1F1E6);
    }).join();
  }

  /// All entries sorted longest-prefix-first so NANP (+1242…) matches
  /// before the generic +1 (US).
  static final _sortedEntries = () {
    final entries = _prefixToIso.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    return entries.map((e) => (e.key, e.value)).toList();
  }();

  // Prefix → ISO 3166-1 alpha-2
  // NANP (+1) countries listed with 4-digit prefixes so they take priority.
  static const _prefixToIso = <String, String>{
    // ── NANP (+1) — area code disambiguated ──────────────────────────────
    '+1242': 'BS', // Bahamas
    '+1246': 'BB', // Barbados
    '+1264': 'AI', // Anguilla
    '+1268': 'AG', // Antigua and Barbuda
    '+1284': 'VG', // British Virgin Islands
    '+1340': 'VI', // US Virgin Islands
    '+1345': 'KY', // Cayman Islands
    '+1441': 'BM', // Bermuda
    '+1473': 'GD', // Grenada
    '+1649': 'TC', // Turks and Caicos Islands
    '+1664': 'MS', // Montserrat
    '+1670': 'MP', // Northern Mariana Islands
    '+1671': 'GU', // Guam
    '+1684': 'AS', // American Samoa
    '+1721': 'SX', // Sint Maarten
    '+1758': 'LC', // Saint Lucia
    '+1767': 'DM', // Dominica
    '+1784': 'VC', // Saint Vincent and the Grenadines
    '+1787': 'PR', // Puerto Rico
    '+1809': 'DO', // Dominican Republic
    '+1829': 'DO', // Dominican Republic
    '+1849': 'DO', // Dominican Republic
    '+1868': 'TT', // Trinidad and Tobago
    '+1869': 'KN', // Saint Kitts and Nevis
    '+1876': 'JM', // Jamaica
    '+1939': 'PR', // Puerto Rico
    '+1': 'US',    // United States / Canada (default)

    // ── Russia / Kazakhstan (+7) ─────────────────────────────────────────
    '+76': 'KZ', // Kazakhstan (Almaty)
    '+77': 'KZ', // Kazakhstan
    '+7': 'RU',  // Russia

    // ── Africa ──────────────────────────────────────────────────────────
    '+20':  'EG', // Egypt
    '+212': 'MA', // Morocco
    '+213': 'DZ', // Algeria
    '+216': 'TN', // Tunisia
    '+218': 'LY', // Libya
    '+220': 'GM', // Gambia
    '+221': 'SN', // Senegal
    '+222': 'MR', // Mauritania
    '+223': 'ML', // Mali
    '+224': 'GN', // Guinea
    '+225': 'CI', // Ivory Coast
    '+226': 'BF', // Burkina Faso
    '+227': 'NE', // Niger
    '+228': 'TG', // Togo
    '+229': 'BJ', // Benin
    '+230': 'MU', // Mauritius
    '+231': 'LR', // Liberia
    '+232': 'SL', // Sierra Leone
    '+233': 'GH', // Ghana
    '+234': 'NG', // Nigeria
    '+235': 'TD', // Chad
    '+236': 'CF', // Central African Republic
    '+237': 'CM', // Cameroon
    '+238': 'CV', // Cape Verde
    '+239': 'ST', // São Tomé and Príncipe
    '+240': 'GQ', // Equatorial Guinea
    '+241': 'GA', // Gabon
    '+242': 'CG', // Republic of the Congo
    '+243': 'CD', // DR Congo
    '+244': 'AO', // Angola
    '+245': 'GW', // Guinea-Bissau
    '+246': 'IO', // British Indian Ocean Territory
    '+247': 'AC', // Ascension Island
    '+248': 'SC', // Seychelles
    '+249': 'SD', // Sudan
    '+250': 'RW', // Rwanda
    '+251': 'ET', // Ethiopia
    '+252': 'SO', // Somalia
    '+253': 'DJ', // Djibouti
    '+254': 'KE', // Kenya
    '+255': 'TZ', // Tanzania
    '+256': 'UG', // Uganda
    '+257': 'BI', // Burundi
    '+258': 'MZ', // Mozambique
    '+260': 'ZM', // Zambia
    '+261': 'MG', // Madagascar
    '+262': 'RE', // Réunion / Mayotte
    '+263': 'ZW', // Zimbabwe
    '+264': 'NA', // Namibia
    '+265': 'MW', // Malawi
    '+266': 'LS', // Lesotho
    '+267': 'BW', // Botswana
    '+268': 'SZ', // Eswatini
    '+269': 'KM', // Comoros
    '+27':  'ZA', // South Africa
    '+290': 'SH', // Saint Helena
    '+291': 'ER', // Eritrea
    '+297': 'AW', // Aruba
    '+298': 'FO', // Faroe Islands
    '+299': 'GL', // Greenland

    // ── Europe ──────────────────────────────────────────────────────────
    '+30':  'GR', // Greece
    '+31':  'NL', // Netherlands
    '+32':  'BE', // Belgium
    '+33':  'FR', // France
    '+34':  'ES', // Spain
    '+350': 'GI', // Gibraltar
    '+351': 'PT', // Portugal
    '+352': 'LU', // Luxembourg
    '+353': 'IE', // Ireland
    '+354': 'IS', // Iceland
    '+355': 'AL', // Albania
    '+356': 'MT', // Malta
    '+357': 'CY', // Cyprus
    '+358': 'FI', // Finland
    '+359': 'BG', // Bulgaria
    '+36':  'HU', // Hungary
    '+370': 'LT', // Lithuania
    '+371': 'LV', // Latvia
    '+372': 'EE', // Estonia
    '+373': 'MD', // Moldova
    '+374': 'AM', // Armenia
    '+375': 'BY', // Belarus
    '+376': 'AD', // Andorra
    '+377': 'MC', // Monaco
    '+378': 'SM', // San Marino
    '+380': 'UA', // Ukraine
    '+381': 'RS', // Serbia
    '+382': 'ME', // Montenegro
    '+383': 'XK', // Kosovo
    '+385': 'HR', // Croatia
    '+386': 'SI', // Slovenia
    '+387': 'BA', // Bosnia and Herzegovina
    '+389': 'MK', // North Macedonia
    '+39':  'IT', // Italy
    '+40':  'RO', // Romania
    '+41':  'CH', // Switzerland
    '+420': 'CZ', // Czech Republic
    '+421': 'SK', // Slovakia
    '+423': 'LI', // Liechtenstein
    '+43':  'AT', // Austria
    '+44':  'GB', // United Kingdom
    '+45':  'DK', // Denmark
    '+46':  'SE', // Sweden
    '+47':  'NO', // Norway
    '+48':  'PL', // Poland
    '+49':  'DE', // Germany

    // ── Latin America ───────────────────────────────────────────────────
    '+500': 'FK', // Falkland Islands
    '+501': 'BZ', // Belize
    '+502': 'GT', // Guatemala
    '+503': 'SV', // El Salvador
    '+504': 'HN', // Honduras
    '+505': 'NI', // Nicaragua
    '+506': 'CR', // Costa Rica
    '+507': 'PA', // Panama
    '+508': 'PM', // Saint Pierre and Miquelon
    '+509': 'HT', // Haiti
    '+51':  'PE', // Peru
    '+52':  'MX', // Mexico
    '+53':  'CU', // Cuba
    '+54':  'AR', // Argentina
    '+55':  'BR', // Brazil
    '+56':  'CL', // Chile
    '+57':  'CO', // Colombia
    '+58':  'VE', // Venezuela
    '+590': 'GP', // Guadeloupe
    '+591': 'BO', // Bolivia
    '+592': 'GY', // Guyana
    '+593': 'EC', // Ecuador
    '+594': 'GF', // French Guiana
    '+595': 'PY', // Paraguay
    '+596': 'MQ', // Martinique
    '+597': 'SR', // Suriname
    '+598': 'UY', // Uruguay
    '+599': 'CW', // Curaçao / Netherlands Antilles

    // ── Asia Pacific ────────────────────────────────────────────────────
    '+60':  'MY', // Malaysia
    '+61':  'AU', // Australia
    '+62':  'ID', // Indonesia
    '+63':  'PH', // Philippines
    '+64':  'NZ', // New Zealand
    '+65':  'SG', // Singapore
    '+66':  'TH', // Thailand
    '+670': 'TL', // Timor-Leste
    '+672': 'NF', // Norfolk Island
    '+673': 'BN', // Brunei
    '+674': 'NR', // Nauru
    '+675': 'PG', // Papua New Guinea
    '+676': 'TO', // Tonga
    '+677': 'SB', // Solomon Islands
    '+678': 'VU', // Vanuatu
    '+679': 'FJ', // Fiji
    '+680': 'PW', // Palau
    '+681': 'WF', // Wallis and Futuna
    '+682': 'CK', // Cook Islands
    '+683': 'NU', // Niue
    '+685': 'WS', // Samoa
    '+686': 'KI', // Kiribati
    '+687': 'NC', // New Caledonia
    '+688': 'TV', // Tuvalu
    '+689': 'PF', // French Polynesia
    '+690': 'TK', // Tokelau
    '+691': 'FM', // Micronesia
    '+692': 'MH', // Marshall Islands
    '+81':  'JP', // Japan
    '+82':  'KR', // South Korea
    '+84':  'VN', // Vietnam
    '+850': 'KP', // North Korea
    '+852': 'HK', // Hong Kong
    '+853': 'MO', // Macau
    '+855': 'KH', // Cambodia
    '+856': 'LA', // Laos
    '+86':  'CN', // China
    '+880': 'BD', // Bangladesh
    '+886': 'TW', // Taiwan

    // ── Middle East ─────────────────────────────────────────────────────
    '+90':  'TR', // Turkey
    '+960': 'MV', // Maldives
    '+961': 'LB', // Lebanon
    '+962': 'JO', // Jordan
    '+963': 'SY', // Syria
    '+964': 'IQ', // Iraq
    '+965': 'KW', // Kuwait
    '+966': 'SA', // Saudi Arabia
    '+967': 'YE', // Yemen
    '+968': 'OM', // Oman
    '+970': 'PS', // Palestinian Territories
    '+971': 'AE', // UAE
    '+972': 'IL', // Israel
    '+973': 'BH', // Bahrain
    '+974': 'QA', // Qatar

    // ── South Asia ──────────────────────────────────────────────────────
    '+91':  'IN', // India
    '+92':  'PK', // Pakistan
    '+93':  'AF', // Afghanistan
    '+94':  'LK', // Sri Lanka
    '+95':  'MM', // Myanmar
    '+975': 'BT', // Bhutan
    '+976': 'MN', // Mongolia
    '+977': 'NP', // Nepal
    '+98':  'IR', // Iran

    // ── Central Asia ────────────────────────────────────────────────────
    '+992': 'TJ', // Tajikistan
    '+993': 'TM', // Turkmenistan
    '+994': 'AZ', // Azerbaijan
    '+995': 'GE', // Georgia
    '+996': 'KG', // Kyrgyzstan
    '+998': 'UZ', // Uzbekistan
  };
}
