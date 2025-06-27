// // In a widget or provider
// class UserProfileWidget extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ElevatedButton(
//       onPressed: () async {
//         // Using the use case
//         final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
//         final result = await getCurrentUser();
        
//         result.fold(
//           (failure) => print('Error: ${failure.message}'),
//           (user) => print('User: ${user.name}, ${user.email}'),
//         );
//       },
//       child: Text('Get Profile'),
//     );
//   }
// }

// // Or directly in the auth state provider
// Future<void> fetchUserProfile() async {
//   final result = await _getCurrentUserUseCase();
//   result.fold(
//     (failure) {
//       state = state.copyWith(error: failure.message);
//     },
//     (user) {
//       state = state.copyWith(user: user);
//     },
//   );
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/core/localization/app_localizations.dart';
import 'package:property_manager_app/src/core/utils/jwt_decoder_util.dart';
import 'package:property_manager_app/src/presentation/providers/auth_state_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<IconData> _icons = [
    Icons.home,
    Icons.people,
    Icons.build,
    Icons.analytics,
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.appTitle),
        actions: [
          // Token status indicator
          if (authState.accessToken != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.green,
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            )
          else if (authState.isAuthenticated)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.orange,
                child: const Icon(
                  Icons.sync,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  // TODO: Navigate to profile
                  break;
                case 'settings':
                  // TODO: Navigate to settings
                  break;
                case 'refresh_token':
                  await ref.read(authStateProvider.notifier).forceRefreshToken();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Token refreshed')),
                  );
                  break;
                case 'token_info':
                  _showTokenInfo(context, authState);
                  break;
                case 'logout':
                  await _showLogoutDialog(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(l10n.profile),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(l10n.settings),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'refresh_token',
                child: ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Refresh Token'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'token_info',
                child: ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Token Info'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    l10n.logout,
                    style: const TextStyle(color: Colors.red),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_icons[0]),
            label: l10n.properties,
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[1]),
            label: l10n.tenants,
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[2]),
            label: l10n.maintenance,
          ),
          BottomNavigationBarItem(
            icon: Icon(_icons[3]),
            label: l10n.reports,
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // TODO: Navigate to add property
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const _PropertiesTab();
      case 1:
        return const _TenantsTab();
      case 2:
        return const _MaintenanceTab();
      case 3:
        return const _ReportsTab();
      default:
        return const _PropertiesTab();
    }
  }

  void _showTokenInfo(BuildContext context, AuthState authState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow('Authenticated:', authState.isAuthenticated.toString()),
            _InfoRow('User:', authState.user?.name ?? 'N/A'),
            _InfoRow('Email:', authState.user?.email ?? 'N/A'),
            const SizedBox(height: 8),
            if (authState.accessToken != null) ...[
              const Text('Access Token:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              _InfoRow('Expires:', JwtDecoderUtil.getExpiryTime(authState.accessToken!).toString()),
              _InfoRow('Time Left:', JwtDecoderUtil.getTimeUntilExpiry(authState.accessToken!).toString()),
              _InfoRow('Is Expired:', JwtDecoderUtil.isTokenExpired(authState.accessToken!).toString()),
            ] else ...[
              const Text('No Access Token Available', style: TextStyle(color: Colors.orange)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... (Previous tab implementations remain the same)
class _PropertiesTab extends StatelessWidget {
  const _PropertiesTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n!.search,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // TODO: Implement filter
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 5, // Mock data
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.home),
                  ),
                  title: Text('Property ${index + 1}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('123 Main St, City'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: index % 2 == 0 ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              index % 2 == 0 ? l10n.available : l10n.occupied,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '\${(index + 1) * 500}/month',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      // TODO: Handle menu actions
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'view',
                        child: Text(l10n.propertyDetails),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(l10n.edit),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          l10n.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TenantsTab extends StatelessWidget {
  const _TenantsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('T${index + 1}'),
            ),
            title: Text('Tenant ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('tenant${index + 1}@email.com'),
                Text('Property ${index + 1}'),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to tenant details
            },
          ),
        );
      },
    );
  }
}

class _MaintenanceTab extends StatelessWidget {
  const _MaintenanceTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: ListTile(
            leading: Icon(
              Icons.build,
              color: index % 2 == 0 ? Colors.orange : Colors.red,
            ),
            title: Text('Maintenance Request ${index + 1}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Property ${index + 1}'),
                Text('Priority: ${index % 2 == 0 ? 'Medium' : 'High'}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: index % 3 == 0 ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                index % 3 == 0 ? 'Completed' : 'Pending',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Properties',
                  value: '12',
                  icon: Icons.home,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Occupied',
                  value: '8',
                  icon: Icons.people,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Monthly Revenue',
                  value: '\$4,500',
                  icon: Icons.attach_money,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Maintenance',
                  value: '3',
                  icon: Icons.build,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}