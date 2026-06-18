import 'package:flutter/material.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/animated_page.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/section_title.dart';
import '../../../models/app_user.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen User')),
      body: AnimatedPage(
        child: StreamBuilder<List<AppUser>>(
          stream: DatabaseService.instance.usersStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LoadingView();
            final users = snapshot.data!;
            if (users.isEmpty) return const EmptyState(title: 'Belum ada user', subtitle: 'User yang terdaftar akan muncul di sini.', icon: Icons.people_outline);

            return SingleChildScrollView(
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle(
                      title: 'Semua User',
                      subtitle: '${users.length} user terdaftar',
                    ),
                    const SizedBox(height: 14),
                    ...users.map((u) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _UserCard(user: u),
                    )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final isSelf = AuthService.instance.currentUser?.uid == user.id;
    final initials = user.name.trim().isEmpty
        ? '?'
        : user.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.cream,
              child: Text(initials, style: const TextStyle(color: AppColors.mocha, fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name.isEmpty ? '(Tanpa nama)' : user.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: -0.1),
                        ),
                      ),
                      if (isSelf)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text('Anda', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.muted)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(user.email, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                  if (user.phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(user.phone, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (!isSelf)
              _RoleDropdown(user: user)
            else
              _RoleBadge(role: user.role),
          ],
        ),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: user.role,
          isDense: true,
          borderRadius: BorderRadius.circular(14),
          items: const [
            DropdownMenuItem(value: 'customer', child: Text('Customer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            DropdownMenuItem(value: 'admin',    child: Text('Admin',    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          ],
          onChanged: (newRole) async {
            if (newRole == null || newRole == user.role) return;
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text('Ubah Role'),
                content: Text('Ubah role ${user.name} menjadi "$newRole"?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, Ubah')),
                ],
              ),
            );
            if (confirm == true) {
              await DatabaseService.instance.updateUserRole(uid: user.id, role: newRole);
            }
          },
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.espresso.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.espresso.withOpacity(0.2)),
      ),
      child: Text(
        role == 'admin' ? 'Admin' : 'Customer',
        style: const TextStyle(color: AppColors.espresso, fontWeight: FontWeight.w700, fontSize: 12.5),
      ),
    );
  }
}