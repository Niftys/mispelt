import 'package:flutter/material.dart';
import '../services/word_service.dart';
import '../utils/constants.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _isSyncing = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.text,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Word Database Management',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Manage your word database by syncing from the local JSON file to Firestore.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sync to Firestore button
            ElevatedButton.icon(
              onPressed: _isSyncing ? null : _syncWordsToFirestore,
              icon:
                  _isSyncing
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.cloud_upload),
              label: Text(
                _isSyncing ? 'Syncing...' : 'Sync Words to Firestore',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Clear cache button
            ElevatedButton.icon(
              onPressed: _clearCache,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Word Cache'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.secondary,
              ),
            ),

            const SizedBox(height: 24),

            // Status message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _statusMessage.contains('Error')
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        _statusMessage.contains('Error')
                            ? Colors.red.shade300
                            : Colors.green.shade300,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color:
                        _statusMessage.contains('Error')
                            ? Colors.red.shade800
                            : Colors.green.shade800,
                  ),
                ),
              ),

            const Spacer(),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Edit words in assets/data/words.json\n'
                      '2. Click "Sync Words to Firestore" to update the database\n'
                      '3. Click "Clear Word Cache" if you need to reload from JSON\n'
                      '4. The app will automatically use Firestore if available, otherwise fall back to JSON',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _syncWordsToFirestore() async {
    setState(() {
      _isSyncing = true;
      _statusMessage = '';
    });

    try {
      await WordService.syncWordsToFirestore();
      setState(() {
        _statusMessage = 'Successfully synced words to Firestore!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error syncing to Firestore: $e';
      });
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  void _clearCache() {
    WordService.clearCache();
    setState(() {
      _statusMessage = 'Word cache cleared successfully!';
    });
  }
}
