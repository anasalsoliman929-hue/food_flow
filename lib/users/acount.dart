import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ تعديل كلمة المرور
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ✅ تعديل البروفايل
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _usernameController.text = prefs.getString("username") ?? '';
    _phoneController.text = prefs.getString("phone") ?? '';
  }

  Future<void> _changePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    setState(() => _isLoading = true);

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/api/settings/change-password"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "current_password": _currentPasswordController.text,
        "new_password": _newPasswordController.text,
        "new_password_confirmation": _confirmPasswordController.text,
      }),
    );

    setState(() => _isLoading = false);

    final data = jsonDecode(response.body);
    _showMessageDialog(data["message"], response.statusCode == 200);
  }

  Future<void> _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return;

    setState(() => _isLoading = true);

    final response = await http.put(
      Uri.parse("http://10.0.2.2:8000/api/settings/update-profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": _usernameController.text,
        "phone": _phoneController.text,
      }),
    );

    setState(() => _isLoading = false);

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // تحديث القيم المخزنة
      await prefs.setString("username", data["user"]["username"]);
      await prefs.setString("phone", data["user"]["phone"]);
    }

    _showMessageDialog(data["message"], response.statusCode == 200);
  }

  void _showMessageDialog(String message, bool success) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Icon(success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red, size: 48),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إغلاق"),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orange,
          tabs: const [
            Tab(text: "تعديل الملف الشخصي"),
            Tab(text: "تغيير كلمة المرور"),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // ✅ تبويب تعديل الملف الشخصي
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInputField(_usernameController, "الاسم"),
                      _buildInputField(_phoneController, "رقم الهاتف"),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _updateProfile,
                        icon: const Icon(Icons.save),
                        label: const Text("حفظ التغييرات"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ تبويب تغيير كلمة المرور
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      _buildInputField(
                          _currentPasswordController, "كلمة المرور الحالية",
                          obscure: true),
                      _buildInputField(
                          _newPasswordController, "كلمة المرور الجديدة",
                          obscure: true),
                      _buildInputField(
                          _confirmPasswordController, "تأكيد كلمة المرور",
                          obscure: true),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _changePassword,
                        icon: const Icon(Icons.lock_reset),
                        label: const Text("تغيير كلمة المرور"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
