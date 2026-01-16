import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../model/UserModel.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';
import 'user_list_screen.dart';
import 'transaction_list_screen.dart';
import 'review_list_screen.dart';
import 'report_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserData? user = authProvider.user;
    final bool isOwner = user != null && user.role == 'owner';

    /// LIST HALAMAN SESUAI TAB
    final List<Widget> pages = [
      _homeContent(user),
      const ProductListScreen(),
      const TransactionListScreen(),
      const ReviewListScreen(),
      if (isOwner) const UserListScreen(),
      if (isOwner) const ReportTransactionScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apotek Pharmacy'),
        backgroundColor: const Color(0xFF00695C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),

      /// BODY BERDASARKAN TAB
      body: pages[_currentIndex],

      /// BOTTOM NAVBAR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00695C),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.medication_outlined),
            label: 'Produk',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Transaksi',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.reviews_outlined),
            label: 'Review',
          ),
          if (isOwner)
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              label: 'Users',
            ),
          if (isOwner)
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              label: 'Laporan',
            ),
        ],
      ),
    );
  }

  /// ================= HOME CONTENT =================
  Widget _homeContent(UserData? user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF4DB6AC),
                  Color(0xFF00695C),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Color(0xFF00695C),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang 👋',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Role: ${user?.role.toUpperCase() ?? ""}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// INFO HOME (BISA DITAMBAH KONTEN)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFF00695C)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gunakan menu di bawah untuk mengelola produk, transaksi, dan data lainnya.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
