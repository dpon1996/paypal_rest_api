
class ShippingAddress {
  ShippingAddress({
    required this.recipientName,
    required this.line1,
    required this.line2,
    required this.city,
    required this.countryCode,
    required this.postalCode,
    required this.phone,
    required this.state,
  });

  String recipientName;
  String line1;
  String line2;
  String city;
  String countryCode;
  String postalCode;
  String phone;
  String state;


  Map<String, dynamic> toJson() => {
    "recipient_name": recipientName,
    "line1": line1,
    "line2": line2,
    "city": city,
    "country_code": countryCode,
    "postal_code": postalCode,
    "phone": phone,
    "state": state,
  };
}
