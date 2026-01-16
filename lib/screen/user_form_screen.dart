import 'package:flutter/material.dart';
import '../model/UserModel.dart';
import '../api/user_service.dart';

class UserFormScreen extends StatefulWidget {
  final UserData? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole;
  String? _selectedShift;

  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _emailController.text = widget.user!.email ?? '';
      _phoneController.text = widget.user!.phone ?? '';
      _selectedRole = widget.user!.role;
      _selectedShift = widget.user!.shift;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = UserData(
      id: widget.user?.id,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole ?? 'apoteker',
      shift: _selectedShift == 'none' ? null : _selectedShift,
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text.trim()
          : null,
    );

    try {
      final success = widget.user != null
          ? await _userService.updateUser(widget.user!.id!, user)
          : await _userService.createUser(user);

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.user != null
                  ? 'User berhasil diupdate'
                  : 'User berhasil ditambahkan',
            ),
            backgroundColor: const Color(0xFF00695C),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.user != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit User' : 'Tambah User'),
        backgroundColor: const Color(0xFF00695C),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ================= Nama =================
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // ================= Email =================
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // ================= Phone =================
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // ================= Password =================
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isEditing
                      ? 'Password (kosongkan jika tidak diubah)'
                      : 'Password',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (!isEditing && (v == null || v.isEmpty)) {
                    return 'Password wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ================= Role =================
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'owner', child: Text('Owner')),
                  DropdownMenuItem(value: 'apoteker', child: Text('Apoteker')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v),
                validator: (v) => v == null ? 'Role wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              // ================= Shift =================
              DropdownButtonFormField<String>(
                value: _selectedShift,
                decoration: const InputDecoration(
                  labelText: 'Shift',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Tidak ada')),
                  DropdownMenuItem(value: 'pagi', child: Text('Pagi')),
                  DropdownMenuItem(value: 'malam', child: Text('Malam')),
                ],
                onChanged: (v) => setState(() => _selectedShift = v),
              ),
              const SizedBox(height: 24),

              // ================= BUTTON =================
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF00695C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  isEditing ? 'Update User' : 'Simpan User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
