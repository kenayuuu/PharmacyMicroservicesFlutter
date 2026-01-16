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
  String? _selectedRole;
  String? _selectedShift;
  final UserService _userService = UserService();
  bool _isLoading = false;
  final _passwordController = TextEditingController();

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
      role: _selectedRole ?? 'apoteker',
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      shift: _selectedShift,
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text.trim()
          : null,
    );

    bool success = false;

    try {
      if (widget.user != null) {
        success = await _userService.updateUser(widget.user!.id!, user);
      } else {
        if (user.password == null || user.password!.isEmpty) {
          throw Exception('Password wajib diisi saat membuat user');
        }
        success = await _userService.createUser(user);
      }

      if (success && mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user != null
                ? 'User berhasil diupdate'
                : 'User berhasil ditambahkan'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user != null ? 'Edit User' : 'Tambah User'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nama', border: OutlineInputBorder()),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              if (widget.user == null)
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: 'Password', border: OutlineInputBorder()),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Password wajib diisi' : null,
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                    labelText: 'Role', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'owner', child: Text('Owner')),
                  DropdownMenuItem(value: 'apoteker', child: Text('Apoteker')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Role wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedShift,
                decoration: const InputDecoration(
                    labelText: 'Shift', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Tidak ada')),
                  DropdownMenuItem(value: 'pagi', child: Text('Pagi')),
                  DropdownMenuItem(value: 'malam', child: Text('Malam')),
                ],
                onChanged: (v) => setState(() => _selectedShift = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveUser,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(widget.user != null ? 'Update' : 'Simpan'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
