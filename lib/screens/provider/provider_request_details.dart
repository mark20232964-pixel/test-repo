import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'assign_mechanic_screen.dart';

class ProviderRequestDetailsScreen extends StatefulWidget {
  const ProviderRequestDetailsScreen({
    super.key,
    required this.requestId,
    required this.data,
  });

  final String requestId;
  final Map<String, dynamic> data;

  @override
  State<ProviderRequestDetailsScreen> createState() =>
      _ProviderRequestDetailsScreenState();
}

class _ProviderRequestDetailsScreenState
    extends State<ProviderRequestDetailsScreen> {
  String? assignedMechanic;

  @override
  void initState() {
    super.initState();
    assignedMechanic = widget.data['assignedMechanic'];
  }

  Future<void> completeService(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.requestId)
        .update({'status': 'completed'});

    Navigator.pop(context);
  }

  Future<void> cancelService(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.requestId)
        .update({'status': 'cancelled'});

    Navigator.pop(context);
  }

  Future<void> assignMechanic() async {
    final selectedMechanic = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignMechanicScreen(
          requestId: widget.requestId,
        ),
      ),
    );

    if (selectedMechanic != null) {
      setState(() {
        assignedMechanic = selectedMechanic;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 40, left: 20, right: 20, bottom: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF1B1B4B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['userName'] ?? "User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data['issue'] ?? "",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ✅ SHOW ASSIGNED MECHANIC
                    if (assignedMechanic != null)
                      Text(
                        "Assigned Mechanic: $assignedMechanic",
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // 🔥 ASSIGN BUTTON (ONLY IF NOT ASSIGNED)
                    if (assignedMechanic == null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: assignMechanic,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text("Assign Mechanic"),
                        ),
                      ),

                    if (assignedMechanic == null) const SizedBox(height: 15),

                    // COMPLETE
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => completeService(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Service Completed"),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // CANCEL
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => cancelService(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Cancel Service"),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // PAYMENT
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Proceed to Payment"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
