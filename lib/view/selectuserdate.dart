import 'package:flutter/material.dart';
import 'package:hotelbookingapp/view/bookinguserpage.dart';

class HotelSearchScreen extends StatefulWidget {
  final String hotelName;
  final String hotelImage;
  final String price;
  final String hotelId;

  const HotelSearchScreen({
    super.key,
    required this.hotelName,
    required this.hotelImage,
    required this.price,
    required this.hotelId,
  });

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  DateTime? checkInDate;
  DateTime? checkOutDate;

  int guests = 1;
  int rooms = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          "Select Dates",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _dateField("Check-in", checkInDate, (date) {
              setState(() => checkInDate = date);
            }),
            _dateField("Check-out", checkOutDate, (date) {
              setState(() => checkOutDate = date);
            }),

            const SizedBox(height: 20),

            _counter("Guests", guests, (v) => setState(() => guests = v)),
            _counter("Rooms", rooms, (v) => setState(() => rooms = v)),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                if (checkInDate == null || checkOutDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Select dates",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingSummary(
                      hotelName: widget.hotelName,
                      hotelImage: widget.hotelImage,
                      price: widget.price,
                      hotelId: widget.hotelId,
                      checkin: checkInDate!,
                      checkout: checkOutDate!,
                      guests: guests,
                      rooms: rooms,
                    ),
                  ),
                );
              },
              child: const Text(
                "FIND",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime? value, Function(DateTime) onPick) {
    return ListTile(
      title: Text(label),
      trailing: Text(
        value == null ? "Select" : "${value.day}/${value.month}/${value.year}",
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
    );
  }

  Widget _counter(String title, int value, Function(int) onChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: value > 1 ? () => onChange(value - 1) : null,
            ),
            Text(value.toString()),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onChange(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}
