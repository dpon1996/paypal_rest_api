
class BasicData {
  BasicData({
    required this.amount,
    required this.currency,
    required this.invoiceNumber,
    required this.description,

  });

  double amount;
  String currency;
  String invoiceNumber;
  String description;


  Map<String, dynamic> toJson() => {
    "amount": amount,
    "currency": currency,
    "invoice_number": invoiceNumber,

  };
}
