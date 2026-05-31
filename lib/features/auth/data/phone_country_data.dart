class CountryOption {
  const CountryOption({
    required this.name,
    required this.prefix,
    required this.placeholder,
  });

  final String name;
  final String prefix;
  final String placeholder;
}

const countries = [
  CountryOption(
    name: 'United States',
    prefix: '+1',
    placeholder: '(000) 000-0000',
  ),
  CountryOption(name: 'Canada', prefix: '+1', placeholder: '(000) 000-0000'),
  CountryOption(name: 'Singapore', prefix: '+65', placeholder: '0000 0000'),
  CountryOption(name: 'Argentina', prefix: '+54', placeholder: '00 0000 0000'),
  CountryOption(name: 'Australia', prefix: '+61', placeholder: '000 000 000'),
  CountryOption(name: 'Austria', prefix: '+43', placeholder: '000 000000'),
  CountryOption(name: 'Belgium', prefix: '+32', placeholder: '000 00 00 00'),
  CountryOption(name: 'Brazil', prefix: '+55', placeholder: '(00) 00000-0000'),
  CountryOption(name: 'Chile', prefix: '+56', placeholder: '0 0000 0000'),
  CountryOption(name: 'Colombia', prefix: '+57', placeholder: '000 0000000'),
  CountryOption(name: 'Costa Rica', prefix: '+506', placeholder: '0000 0000'),
  CountryOption(
    name: 'Czech Republic',
    prefix: '+420',
    placeholder: '000 000 000',
  ),
];
