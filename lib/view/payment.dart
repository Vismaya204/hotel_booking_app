import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/success.dart';

class Payment extends StatefulWidget {
  final String hotelId;
  final String hotelName;
  final String hotelImage;
  final int price;
  final DateTime checkin;
  final DateTime checkout;
  final int guests;
  final int rooms;
  final String? email;

  const Payment({
    super.key,
    required this.hotelId,
    required this.hotelName,
    required this.hotelImage,
    required this.price,
    required this.checkin,
    required this.checkout,
    required this.guests,
    required this.rooms,
     this.email,
  });

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {

  final ValueNotifier<String> selectedPay = ValueNotifier("gpay");

  final TextEditingController cardHolderCtrl = TextEditingController();
  final TextEditingController cardNumberCtrl = TextEditingController();
  final TextEditingController expiryCtrl     = TextEditingController();
  final TextEditingController cvvCtrl        = TextEditingController();
bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment",
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // PRICE BOX
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Price",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "₹${widget.price}",
                    style: const TextStyle(
                      fontSize: 34,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "GST included",
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Payment method",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            ValueListenableBuilder(
              valueListenable: selectedPay,
              builder: (context, value, _) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  payOption("assets/visalogo.png", "visa", value),
                  payOption("assets/mastercard.png", "master", value),
                  payOption("assets/payoneer.png", "pioneer", value),
                  payOption("assets/gpayimg.jpeg", "gpay", value),
                ],
              ),
            ),

            const SizedBox(height: 35),

            _inputField("Card Holder Name", "Your Name", cardHolderCtrl),
            _inputField("Card Number", "**** **** **** ****", cardNumberCtrl),

            Row(
              children: [
                Expanded(child: _inputField("Expiry date", "MM/YY", expiryCtrl)),
                const SizedBox(width: 15),
                Expanded(child: _inputField("CVV", "***", cvvCtrl)),
              ],
            ),

            const SizedBox(height: 30),

           SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    onPressed: _isLoading ? null : () async {
      if (cardHolderCtrl.text.isEmpty ||
          cardNumberCtrl.text.isEmpty ||
          expiryCtrl.text.isEmpty ||
          cvvCtrl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Fill all fields")),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      setState(() => _isLoading = true);

      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance
            .collection("payments")
            .doc(uid)
            .collection("history")
            .add({
          "hotelName": widget.hotelName,
          "hotelImage": widget.hotelImage,
          "price": widget.price,
          "paymentMethod": selectedPay.value,
          "useremail": user.email,
          "date": FieldValue.serverTimestamp(),
        });

        setState(() => _isLoading = false);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Success()),
        );
      } catch (e) {
        setState(()=> _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    },
    child: _isLoading
        ? const CircularProgressIndicator(color: Colors.white)
        : const Text("PAY NOW", style: TextStyle(fontSize: 18)),
  ),
)

          ],
        ),
      ),
    );
  }

  Widget _inputField(
      String title, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget payOption(String img, String id, String selected) {
    return GestureDetector(
      onTap: () {
        selectedPay.value = id;
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected == id ? Colors.blue : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Image.asset(img, height: 45),
      ),
    );
  }
}
