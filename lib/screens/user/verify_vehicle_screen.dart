import 'package:flutter/material.dart';
import 'vehicle_verification_form_screen.dart';


class VerifyVehicleScreen extends StatefulWidget {
  const VerifyVehicleScreen({super.key});

  @override
  State<VerifyVehicleScreen> createState() => _VerifyVehicleScreenState();
}

class _VerifyVehicleScreenState extends State<VerifyVehicleScreen> {
  String selectedType = 'Car'; 

  
  final Map<String, List<Map<String, String>>> brands = {
  'Car': [
    {'name': 'Toyota', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Ftoyota.jpg?alt=media&token=39e3c18b-a519-47b8-94a5-8cc61e98de0d'},
    {'name': 'Honda', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fhonda.jpg?alt=media&token=4257bbde-2830-4948-b63b-817d6bbf76f2'},
    {'name': 'Nissan', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fnissan.jpg?alt=media&token=2edfdc85-944d-43bb-80e7-bc1137e94040'},
    {'name': 'BMW', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fbmw.jpg?alt=media&token=966ef25c-d3e1-4e58-8353-ac49ff4e093d'},
    {'name': 'Perodua', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fperodua.png?alt=media&token=5adf18f5-43a9-4e52-b794-d0e949fa9fcb'},  
    {'name': 'Suzuki', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fsuzuki.jpg?alt=media&token=6380043d-12c4-4568-8d87-c99e9888b219'},
  ],
  'SUV': [
    {'name': 'Toyota', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Ftoyota.jpg?alt=media&token=39e3c18b-a519-47b8-94a5-8cc61e98de0d'},
    {'name': 'Honda', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fhonda.jpg?alt=media&token=4257bbde-2830-4948-b63b-817d6bbf76f2'},
    {'name': 'Land Rover', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fland_rover.jpg?alt=media&token=e69d31cc-a688-4168-aaa0-2b3f2cca0cda'},
    {'name': 'Jeep', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fjeep.jpg?alt=media&token=b44c49cc-c06e-47e5-bc62-171bc12b2079'},
  ],
  'Van': [
    {'name': 'Toyota', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Ftoyota.jpg?alt=media&token=39e3c18b-a519-47b8-94a5-8cc61e98de0d'},
    {'name': 'Nissan', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fnissan.jpg?alt=media&token=2edfdc85-944d-43bb-80e7-bc1137e94040'},
    {'name': 'HiAce', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fhiace.png?alt=media&token=028f61a3-79b8-4e1c-a287-6f99450d706f'}, 
  ],
  'Bike': [
    {'name': 'Honda', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fhonda.jpg?alt=media&token=4257bbde-2830-4948-b63b-817d6bbf76f2'},
    {'name': 'Yamaha', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fyamaha.png?alt=media&token=0255ecda-2ee1-4784-9ddb-41e07a9374e6'}, 
    {'name': 'Bajaj', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fbajaj.jpg?alt=media&token=671f694a-828f-4946-a181-cf380ea4f3ec'},
    {'name': 'TVS', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Ftvs.png?alt=media&token=ec8820da-31dc-4837-830a-ab26f83bacf7'},
  ],
  'Lorry': [
    {'name': 'Tata', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Ftata.jpg?alt=media&token=d07e907b-6566-462d-801d-c9f5cd252c6b'},
    {'name': 'Isuzu', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fisuzu.png?alt=media&token=bbc9cffb-aa1f-40bb-8fd1-bcb2692be583'},
    {'name': 'Ashok Leyland', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fashok.png?alt=media&token=7077c7ad-ce24-4e81-8d23-a541da6a7f49'},
  ],
  'Three Wheeler': [
    {'name': 'Bajaj', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fbajaj.jpg?alt=media&token=671f694a-828f-4946-a181-cf380ea4f3ec'},
    {'name': 'Piaggio', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Fpiaggio.png?alt=media&token=19f462bd-d442-4031-bbb9-bbaf6b9ead04'},
    {'name': 'TVS', 'logo': 'https://firebasestorage.googleapis.com/v0/b/roadresqsdgp.firebasestorage.app/o/brands%2Ftvs.png?alt=media&token=ec8820da-31dc-4837-830a-ab26f83bacf7'},
  ],
};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Verify Your Vehicle",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Tab bar: Car | SUV | Van | Bike | Lorry | Three Wheeler
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildTab("Car", selectedType == "Car"),
                _buildTab("SUV", selectedType == "SUV"),
                _buildTab("Van", selectedType == "Van"),
                _buildTab("Bike", selectedType == "Bike"),
                _buildTab("Lorry", selectedType == "Lorry"),
                _buildTab("Three Wheeler", selectedType == "Three Wheeler"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Brand list for selected type
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: brands[selectedType]!.length,
              itemBuilder: (context, index) {
                final brand = brands[selectedType]![index];
                return Card(
  color: Colors.white,
  margin: const EdgeInsets.only(bottom: 12),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  child: ListTile(
    leading: CircleAvatar(
  radius: 30,
  backgroundColor: Colors.white,
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Image.network(
      brand['logo']!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A48FF)),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.car_repair,
        color: Colors.grey,
      ),
    ),
  ),
),
    title: Text(
      brand['name']!,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VehicleVerificationFormScreen(
        brandName: brand['name']!,
        logoUrl: brand['logo']!,
      ),
    ),
  );
},
  ),
);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF6A48FF),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 3,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: ""),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF6A48FF),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            label: "",
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A48FF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}