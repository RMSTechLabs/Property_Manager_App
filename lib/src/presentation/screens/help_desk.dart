import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:property_manager_app/src/presentation/providers/society_provider.dart'; // Import your society provider

class HelpDeskScreen extends ConsumerWidget {
  const HelpDeskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSocietyId = ref.watch(selectedSocietyIdProvider);
    print('Selected Society ID in HelpDesk: $selectedSocietyId');
    
    return Scaffold(
      appBar: AppBar(title: const Text('HelpDeskScreen Society Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedSocietyId != null
                  ? 'Selected Society ID: $selectedSocietyId'
                  : 'No Society Selected',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Test changing selected society ID
                ref.read(selectedSocietyIdProvider.notifier).state = 'test-12345';
              },
              child: const Text('Test Change Society ID'),
            ),
          ],
        ),
      ),
    );
  }
}