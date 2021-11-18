library paypal_rest_api;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:paypal_rest_api/modelClass/basicData.dart';
import 'package:paypal_rest_api/modelClass/shippingAddress.dart';
import 'package:paypal_rest_api/showSnackbarMessage.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaypalPayment extends StatefulWidget {
  final String paypalAuthApi;
  final String paypalPaymentApi;
  final BasicData paymentDetails;
  final ShippingAddress shippingAddress;
  final String clientId;
  final String secretKey;
  final String returnUrl;
  final String cancelUrl;
  final String initialUrl;
  final ValueChanged<String> paymentId;

  const PaypalPayment({
    Key? key,
    required this.paypalAuthApi,
    required this.paypalPaymentApi,
    required this.paymentDetails,
    required this.shippingAddress,
    required this.clientId,
    required this.secretKey,
    required this.initialUrl,
    required this.paymentId,
    this.returnUrl = "https://example.com",
    this.cancelUrl = "https://example.com",

  }) : super(key: key);

  @override
  _PaypalPaymentState createState() => _PaypalPaymentState();
}

class _PaypalPaymentState extends State<PaypalPayment> {
  WebViewController? _controller;

  ///payment url
  String approvalUrl = "";

  ///payment conformation
  String executeUrl = "";

  String? authType, token;

  @override
  Widget build(BuildContext context) {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl: widget.initialUrl,
      onPageFinished: _checkSuccess,
      onWebViewCreated: (WebViewController controller) {
        _controller = controller;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  _getToken() async {
    Dio dio = Dio();
    var authCredential = "Basic " +
        base64Encode(utf8.encode("${widget.clientId}:${widget.secretKey}"));

    dio.options.headers = {"authorization": authCredential};
    dio.options.contentType = "application/x-www-form-urlencoded";
    Map<String, String> data = {"grant_type": "client_credentials"};

    try {
      var resp = await dio.post(widget.paypalAuthApi, data: data);

      authType = resp.data["token_type"];
      token = resp.data["access_token"];
      if (token == null) {
        showSnackbarMessage(context, "Something went wrong", onTap: () {
          _getToken();
        });
      } else {
        _paymentApi();
      }
    } catch (e) {
      showSnackbarMessage(context, "Something went wrong", onTap: () {
        _getToken();
      });
    }
  }

  _paymentApi() async {
    Map data = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {
          "amount": {
            "total": "${widget.paymentDetails.amount}",
            "currency": "USD",
            "details": {
              "subtotal": "0.00",
              "tax": "0.00",
              "shipping": "0.00",
              "handling_fee": "0.00",
              "shipping_discount": "0.00",
              "insurance": "0.00"
            }
          },
          "description": "${widget.paymentDetails.description}",
          "custom": "EBAY_EMS_90048630024435",
          "invoice_number": "${widget.paymentDetails.invoiceNumber}",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "soft_descriptor": "ECHI5786786",
          "item_list": {
            "items": [],
            "shipping_address": {
              "recipient_name": "${widget.shippingAddress.recipientName}",
              "line1": "${widget.shippingAddress.line1}",
              "line2": "${widget.shippingAddress.line2}",
              "city": "${widget.shippingAddress.city}",
              "country_code": "${widget.shippingAddress.countryCode}",
              "postal_code": "${widget.shippingAddress.postalCode}",
              "phone": "${widget.shippingAddress.phone}",
              "state": "${widget.shippingAddress.state}"
            }
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {
        "return_url": "${widget.returnUrl}",
        "cancel_url": "${widget.cancelUrl}"
      }
    };
    Dio dio = Dio();
    dio.options.headers = {"authorization": "$authType $token"};
    dio.options.contentType = "application/json";
    try{
      var resp = await dio.post(widget.paypalPaymentApi, data: data);
      if(resp.data["links"] != null){
        List links = resp.data["links"];
        if (links.isNotEmpty) {
          links.forEach((element) {
            if (element["rel"].toString().contains("approval_url")) {
              approvalUrl = element["href"];
            } else if (element["rel"].toString().contains("execute")) {
              executeUrl = element["href"];
            }
          });
        }
        setState(() {});
        _controller?.loadUrl(approvalUrl);
        setState(() {});
      }else{
        showSnackbarMessage(context, "Something went wrong", onTap: () {
          _paymentApi();
        });
      }
    }catch(e){
      showSnackbarMessage(context, "Something went wrong", onTap: () {
        _paymentApi();
      });
    }
  }

  _checkSuccess(String url) {
    FocusScope.of(context).unfocus();
    if(url.contains(widget.returnUrl)){
      String payerId = url.split("PayerID=").last;
      _executePayment(payerId);
    }
  }

  _executePayment(paymentId)async{
    Dio dio = Dio();
    dio.options.headers = {"authorization": "$authType $token"};
    dio.options.contentType = "application/json";
    Map data = {"payer_id": "$paymentId"};

    try{
      var resp = await dio.post(executeUrl,data: data);

      if(resp.data["state"] != null){
        if(resp.data["state"] == "approved"){
          setState(() {
            widget.paymentId(resp.data["id"]);
          });
        }
      }else{
        showSnackbarMessage(context, "Something went wrong", onTap: () {
          _executePayment(paymentId);
        });
      }

    }catch(e){
      showSnackbarMessage(context, "Something went wrong", onTap: () {
        _executePayment(paymentId);
      });
    }

  }

}
