import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int rating = 0;
  final TextEditingController commentController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> submitReview() async {
    if (rating == 0) return;

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection("reviews").add({
        "userId": user?.uid,
        "rating": rating,
        "comment": commentController.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Review submitted successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1B4B),
        title: const Text('Leave a Review'),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              'How was your experience?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // DARKER TEXT
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Your feedback helps us improve.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87, // DARKER than before
              ),
            ),

            const SizedBox(height: 30),

            // ⭐ Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    size: 42,
                    color: index < rating ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () => setState(() => rating = index + 1),
                );
              }),
            ),

            const SizedBox(height: 30),

            // 💬 Comment box (modern card style)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: commentController,
                maxLines: 5,
                style: const TextStyle(color: Colors.black), // DARK TEXT
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tell us what you liked...',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 🚀 Submit Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (rating == 0 || isLoading) ? null : submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B1B4B),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          fontSize: 18, // ✅ requested size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
