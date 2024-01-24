import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:selfcheckoutapp/services/firebase_services.dart';
import 'package:http/http.dart' as http;

FirebaseServices _firebaseServices = FirebaseServices();

class KhaltiPaymentIntentResponse {
  String? message;
  bool? success;

  KhaltiPaymentIntentResponse({this.message, this.success});

  @override
  String toString() {
    return 'KhaltiPaymentIntentResponse{message: $message, success: $success}';
  }
}

class KhaltiTransactionResponse {
  String? message;
  bool? success;

  final double? total;

  KhaltiTransactionResponse({this.total, this.message, this.success});
}

void _getFromCart(String idx) async {
  final DateTime now = DateTime.now();
  // final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm:ss');
//  final String formatted = formatter.format(now);

  _firebaseServices.usersCartRef
      .doc(_firebaseServices.getUserId())
      .collection("Cart")
      .get()
      .then((value) {
    List getFromCart = [value];
    getFromCart.forEach((element) async {
      element.docs.forEach((doc) async {
        _firebaseServices.usersCartHistoryRef
            .doc(_firebaseServices.getUserId())
            .collection("Cart")
            .add({
          'idx': idx,
          'uuid': _firebaseServices.getUserId(),
          'barcode': doc.data()['barcode'],
          'image': doc.data()['image'],
          'name': doc.data()['name'],
          'quantity': doc.data()['quantity'],
          'weight': doc.data()['weight'],
          'price': doc.data()['price'],
          'time': "2020"
        });

        _firebaseServices.cartHistoryForAdminRef.add({
          'idx': idx,
          'uuid': _firebaseServices.getUserId(),
          'barcode': doc.data()['barcode'],
          'image': doc.data()['image'],
          'name': doc.data()['name'],
          'quantity': doc.data()['quantity'],
          'weight': doc.data()['weight'],
          'price': doc.data()['price'],
          'time': "2020"
        });
      });
    });
  });
}

class KhaltiServices {
  static Future<KhaltiTransactionResponse?> payViaKhalti(
      {String? amount,
      String? transaction_pin,
      String? token,
      String? confirmation_code}) async {
    try {
      var headers = {
        'Authorization': 'Key live_secret_key_1c00b2559c13410b8627221b6e8f3792'
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://khalti.com/api/v2/payment/confirm/'));
      request.fields.addAll({
        'transaction_pin': transaction_pin!,
        'confirmation_code': confirmation_code!,
        'token': token!,
        'public_key': 'live_public_key_5382606d8c5f4eaca0fdbd4f5977cf31'
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      var responseBody = await response.stream.bytesToString();
      Map<String, dynamic> responseJson = json.decode(responseBody);
      print(responseJson);
      if (response.statusCode == 200) {
        var request = http.MultipartRequest(
            'POST', Uri.parse('https://khalti.com/api/v2/payment/verify/'));
        request.fields.addAll({'amount': amount!, 'token': token});

        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          Map<String, dynamic> responseJson = json.decode(responseBody);
          var idx = responseJson['idx'];
          if (idx.toString().isNotEmpty) {
            _getFromCart(idx);
            return KhaltiTransactionResponse(
                message: 'Transaction successful', success: true);
          } else {
            return KhaltiTransactionResponse(
                message: 'Transaction failed: IDX not found', success: false);
          }
        } else {
          return KhaltiTransactionResponse(
              message: 'Transaction failed: ${response.reasonPhrase}',
              success: false);
        }
      } else {
        return KhaltiTransactionResponse(
            message: 'Transaction failed: ${response.reasonPhrase}',
            success: false);
      }
    } on PlatformException catch (e) {
      return KhaltiTransactionResponse(
          message: 'Transaction failed: ${e.message}', success: false);
    } catch (e) {
      return KhaltiTransactionResponse(
          message: 'Transaction failed: ${e.toString()}', success: false);
    }
  }

  static getPlatformExceptionErrorResult(e) {
    String message = 'Transaction failed. Something went wrong.';
    if (e.code == 'cancelled') {
      message = 'Transaction cancelled';
    }

    return KhaltiTransactionResponse(message: message, success: false);
  }

  static Future<KhaltiPaymentIntentResponse> createPaymentIntent(
      String amount, String mobile, String transaction_pin) async {
    String? token;

    try {
      var headers = {
        'Authorization': 'Key live_secret_key_1c00b2559c13410b8627221b6e8f3792'
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://khalti.com/api/v2/payment/initiate/'));
      request.fields.addAll({
        'mobile': mobile,
        'amount': amount,
        'transaction_pin': transaction_pin,
        'product_identity': 'test_id',
        'product_name': 'nameofProducy',
        'public_key': 'live_public_key_5382606d8c5f4eaca0fdbd4f5977cf31'
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      var responseBody = await response.stream.bytesToString();
      Map<String, dynamic> responseJson = json.decode(responseBody);
      if (response.statusCode != 200) {
        return KhaltiPaymentIntentResponse(
            message: 'Something went wrong ${responseJson['detail']}',
            success: false);
      }
      token = responseJson['token'];
    } catch (e) {
      print("e charging user: ${e.toString()}");
    }

    if (token == null) {
      return KhaltiPaymentIntentResponse(
          message: "Something went wrong", success: false);
    }
    return KhaltiPaymentIntentResponse(message: token, success: true);
  }
}
