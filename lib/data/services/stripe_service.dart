import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  StripeService._();
  static final StripeService instance = StripeService._();

  Future<bool> makePayment(double amount) async {
    try {
      String? result = await createPaymentIntent(amount, 'mxn');
      
      if (result == null) {
        return false;
      }
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: result,
          merchantDisplayName: 'NiñerApp',
          billingDetails: BillingDetails(
            address: Address(country: 'MX', state: null, city: null, line1: null, line2: null, postalCode: null),
          ),
        )
      );

      await Stripe.instance.presentPaymentSheet();

      return true;
    } on StripeException catch (e) {
      debugPrint('Error de Stripe: ${e.error.message}');
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<String?> createPaymentIntent(double amount, String currency) async {
    await dotenv.load(fileName: ".env");
    final String stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY']!;
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": calculateAmount(amount),
        "currency": currency,
      };
      var response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer $stripeSecretKey',
            'Content-Type': 'application/x-www-form-urlencoded'
          }
        )
      );

      if (response.data != null) {
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  String calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt().toString();
    return calculatedAmount;
  }
}