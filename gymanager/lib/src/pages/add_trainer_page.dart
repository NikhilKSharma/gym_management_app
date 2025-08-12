import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymanager/src/config/app_colors.dart';
import 'package:gymanager/src/services/api_service.dart';

class AddTrainerPage extends StatefulWidget {
  const AddTrainerPage({super.key});

  @override
  State<AddTrainerPage> createState() => _AddTrainerPageState();
}

class _AddTrainerPageState extends State<AddTrainerPage> {
  final _nameController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveTrainer() async {
    if (_nameController.text.isEmpty || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.createTrainer(
        name: _nameController.text,
        gender: _selectedGender!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trainer added successfully!')),
        );
        context.pop(); // Go back to the previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Trainer'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.secondaryText,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  style: const TextStyle(color: AppColors.primaryText),
                  cursorColor: AppColors.primaryText,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  // Set the background color of the dropdown menu
                  dropdownColor: AppColors.background,
                  items: const [
                    DropdownMenuItem(
                      value: 'Male',
                      // Explicitly style the text for the item
                      child: Text('Male',
                          style: TextStyle(color: AppColors.primaryText)),
                    ),
                    DropdownMenuItem(
                      value: 'Female',
                      // Explicitly style the text for the item
                      child: Text('Female',
                          style: TextStyle(color: AppColors.primaryText)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  style: const TextStyle(color: AppColors.primaryText),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _isLoading ? null : _saveTrainer,
                  child: const Text('Save Trainer'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
            ),
        ],
      ),
    );
  }
}
