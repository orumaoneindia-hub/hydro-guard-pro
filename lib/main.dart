import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HydroGuardApp());
}

class HydroGuardApp extends StatelessWidget {
  const HydroGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hydro Guard Pro',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

/* ---------------- 1. PDF SERVICE (FIXED) ---------------- */
class PdfService {
  static Future<void> generateWarranty(Map<String, dynamic> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          // ഇവിടെയാണ് തെറ്റ് ഉണ്ടായിരുന്നത്: 'cross' എന്നത് 'crossAxisAlignment' എന്ന് മാറ്റി
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, child: pw.Text("HYDRO GUARD PRO")),
            pw.Text("WARRANTY CERTIFICATE", style: pw.TextStyle(fontSize: 20)),
            pw.Divider(),
            pw.Text("Customer: ${data['customerName']}"),
            pw.Text("Address: ${data['location']}"),
            pw.Text("Phone: ${data['phone']}"),
            pw.Text("Warranty Period: ${data['warrantyYears']} Years"),
            pw.Text("Completion Date: ${data['completionDate']}"),
            pw.SizedBox(height: 50),
            pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Authorized Signature"))
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}

/* ---------------- 2. MAIN NAVIGATION ---------------- */
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeScreen(),
    const PublicWorksPage(),
    const AcademyScreen(),
    const AdminOfficePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0D47A1),
        onTap: (index) {
          if (index == 3) {
            _showAdminPasswordDialog();
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.location_on), label: 'Works'),
          BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_fill), label: 'Academy'),
          BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings), label: 'Office'),
        ],
      ),
    );
  }

  void _showAdminPasswordDialog() {
    final passC = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Admin Access"),
        content: TextField(
            controller: passC,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Password")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (passC.text == "1234") {
                Navigator.pop(context);
                setState(() => _selectedIndex = 3);
              }
            },
            child: const Text("Login"),
          )
        ],
      ),
    );
  }
}

/* ---------------- 3. HOME SCREEN (FULL RESTORED) ---------------- */
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchC = TextEditingController();

  Future<void> _sendSitePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Site photo sent to office!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hydro Guard Pro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 120),
            const SizedBox(height: 20),
            TextField(
              controller: searchC,
              decoration: InputDecoration(
                hintText: "Enter Registered Phone Number",
                suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() {})),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              keyboardType: TextInputType.phone,
            ),
            if (searchC.text.isNotEmpty) _buildSearchResult(),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _sendSitePhoto,
              icon: const Icon(Icons.camera_enhance),
              label: const Text("SEND SITE PHOTO TO OFFICE"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                backgroundColor: Colors.orange[900],
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _showBookingForm(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
              ),
              child: const Text("BOOK FREE SITE VISIT"),
            ),
            const SizedBox(height: 25),
            _buildContactCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResult() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('projects')
          .where('phone', isEqualTo: searchC.text)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Text("No records found.");
        var d = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        return Card(
          child: ListTile(
            title: Text(d['customerName'] ?? "Customer"),
            subtitle: Text("Status: ${d['status'] ?? 'N/A'}"),
            trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => PdfService.generateWarranty(d)),
          ),
        );
      },
    );
  }

  void _showBookingForm(BuildContext context) {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final locC = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Book Visit",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
                controller: nameC,
                decoration: const InputDecoration(labelText: "Name")),
            TextField(
                controller: phoneC,
                decoration: const InputDecoration(labelText: "Phone")),
            TextField(
                controller: locC,
                decoration: const InputDecoration(labelText: "Location")),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('bookings').add({
                  'name': nameC.text,
                  'phone': phoneC.text,
                  'location': locC.text,
                  'status': 'Pending',
                  'createdAt': FieldValue.serverTimestamp()
                });
                Navigator.pop(context);
              },
              child: const Text("Submit"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: const Column(children: [
        Text("Contact Support", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("+91 8301005081",
            style: TextStyle(fontSize: 18, color: Color(0xFF0D47A1))),
      ]),
    );
  }
}

/* ---------------- 4. ADMIN OFFICE PAGE ---------------- */
class AdminOfficePage extends StatefulWidget {
  const AdminOfficePage({super.key});
  @override
  State<AdminOfficePage> createState() => _AdminOfficePageState();
}

class _AdminOfficePageState extends State<AdminOfficePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Office"),
          bottom: const TabBar(
              tabs: [Tab(text: "Projects"), Tab(text: "Bookings")]),
        ),
        body: TabBarView(
          children: [_buildProjectList(), _buildBookingList()],
        ),
      ),
    );
  }

  Widget _buildProjectList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('projects').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var d = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(d['customerName'] ?? "Unnamed"),
                subtitle: Text(d['location'] ?? "No Location"),
                trailing: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.blue),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? photo =
                        await picker.pickImage(source: ImageSource.camera);
                    if (photo != null) {
                      await GallerySaver.saveImage(photo.path,
                          albumName: "HydroGuard_Works");
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Saved to Gallery!")));
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBookingList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var b = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            return ListTile(
                title: Text(b['name'] ?? "User"),
                subtitle: Text(b['location'] ?? ""));
          },
        );
      },
    );
  }
}

/* ---------------- 5. ACADEMY SCREEN ---------------- */
class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Academy")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('academy').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var v = snapshot.data!.docs[index];
              return ListTile(
                leading: const Icon(Icons.play_circle, color: Colors.red),
                title: Text(v['title'] ?? "Video"),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addVideoDialog(context),
        child: const Icon(Icons.video_call),
      ),
    );
  }

  void _addVideoDialog(BuildContext context) {
    final t = TextEditingController();
    final u = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Training"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: t,
              decoration: const InputDecoration(hintText: "Title")),
          TextField(
              controller: u,
              decoration: const InputDecoration(hintText: "Link"))
        ]),
        actions: [
          ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('academy')
                    .add({'title': t.text, 'url': u.text});
                Navigator.pop(context);
              },
              child: const Text("Add"))
        ],
      ),
    );
  }
}

/* ---------------- 6. PUBLIC WORKS ---------------- */
class PublicWorksPage extends StatelessWidget {
  const PublicWorksPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Portfolio")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('public_works').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var w = snapshot.data!.docs[index];
              return Card(child: Center(child: Text(w['title'] ?? "Work")));
            },
          );
        },
      ),
    );
  }
}
