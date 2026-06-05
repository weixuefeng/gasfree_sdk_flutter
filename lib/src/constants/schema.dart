import '../types.dart';

/// Validates the fields of a GasFree typed data message.
/// Returns null if valid, or an error message string if invalid.
String? validateMessage(GasFreeTypedDataMessage message) {
  if (message.token.isEmpty) return 'token is required';
  if (message.serviceProvider.isEmpty) return 'serviceProvider is required';
  if (message.user.isEmpty) return 'user is required';
  if (message.receiver.isEmpty) return 'receiver is required';

  for (final field in [
    ('value', message.value),
    ('maxFee', message.maxFee),
    ('deadline', message.deadline),
    ('version', message.version),
    ('nonce', message.nonce),
  ]) {
    if (field.$2.isEmpty) return '${field.$1} is required';
    if (!_isValidNumberString(field.$2)) {
      return '${field.$1} must be a non-negative integer string';
    }
  }

  return null;
}

bool _isValidNumberString(String value) {
  if (value.isEmpty) return false;
  // Decimal number
  if (RegExp(r'^\d+$').hasMatch(value)) {
    return BigInt.tryParse(value) != null;
  }
  // Hex number
  if (RegExp(r'^0x[0-9a-fA-F]+$').hasMatch(value)) {
    return true;
  }
  return false;
}
