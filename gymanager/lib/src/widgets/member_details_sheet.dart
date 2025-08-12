import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymanager/src/config/app_colors.dart';
import 'package:gymanager/src/models/member_model.dart';
import 'package:gymanager/src/services/api_service.dart';
import 'package:intl/intl.dart';

class MemberDetailsSheet extends StatelessWidget {
  final Member member;
  final VoidCallback onActionCompleted;

  const MemberDetailsSheet({
    super.key,
    required this.member,
    required this.onActionCompleted,
  });

  // Method to show the renewal dialog
  void _showRenewMembershipDialog(BuildContext context) {
    String? selectedPlan = '1-month'; // Default selection

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          // Use StatefulBuilder to manage dialog's state
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: AppColors.background,
              title: const Text('Renew Membership',
                  style: TextStyle(color: AppColors.primaryText)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('1 Month',
                        style: TextStyle(color: AppColors.primaryText)),
                    value: '1-month',
                    groupValue: selectedPlan,
                    onChanged: (value) => setState(() => selectedPlan = value),
                  ),
                  RadioListTile<String>(
                    title: const Text('3 Months',
                        style: TextStyle(color: AppColors.primaryText)),
                    value: '3-month',
                    groupValue: selectedPlan,
                    onChanged: (value) => setState(() => selectedPlan = value),
                  ),
                  RadioListTile<String>(
                    title: const Text('6 Months',
                        style: TextStyle(color: AppColors.primaryText)),
                    value: '6-month',
                    groupValue: selectedPlan,
                    onChanged: (value) => setState(() => selectedPlan = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.primaryText)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                FilledButton(
                  child: const Text('Confirm Renewal'),
                  onPressed: () async {
                    if (selectedPlan == null) return;
                    try {
                      await ApiService.renewMembership(
                        memberId: member.id,
                        membershipPlan: selectedPlan!,
                      );
                      Navigator.of(ctx).pop(); // Close the dialog
                      context.pop(); // Close the bottom sheet
                      onActionCompleted(); // Refresh the list
                    } catch (e) {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to show delete confirmation
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: const Text('Are you sure?',
            style: TextStyle(color: AppColors.primaryText)),
        content: const Text('Do you want to permanently delete this member?',
            style: TextStyle(color: AppColors.primaryText)),
        actions: <Widget>[
          TextButton(
            child: const Text('No',
                style: TextStyle(color: AppColors.primaryText)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Yes, Delete'),
            onPressed: () async {
              try {
                await ApiService.deleteMember(member.id);
                Navigator.of(ctx).pop();
                context.pop();
                onActionCompleted();
              } catch (e) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = DateTime.now().difference(member.dob).inDays ~/ 365;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            member.name,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(Icons.cake_outlined, 'Age',
              '$age years old (Born ${DateFormat.yMd().format(member.dob)})'),
          if (member.trainerName != null)
            _buildDetailRow(
                Icons.fitness_center_outlined, 'Trainer', member.trainerName!),
          _buildDetailRow(Icons.calendar_today_outlined, 'Membership Expires',
              DateFormat.yMMMd().format(member.membershipEndDate)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.autorenew),
                  label: const Text('Renew'),
                  onPressed: () => _showRenewMembershipDialog(context),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryText),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  onPressed: () => _showDeleteConfirmationDialog(context),
                  style:
                      FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryText.withOpacity(0.7), size: 20),
          const SizedBox(width: 16),
          Text('$label: ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText.withOpacity(0.7))),
          Text(value, style: const TextStyle(color: AppColors.primaryText)),
        ],
      ),
    );
  }
}
