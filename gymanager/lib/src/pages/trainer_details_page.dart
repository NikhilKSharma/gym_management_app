import 'package:flutter/material.dart';
import 'package:gymanager/src/config/app_colors.dart';
import 'package:gymanager/src/models/member_model.dart';
import 'package:gymanager/src/services/api_service.dart';
import 'package:intl/intl.dart';

class TrainerDetailsPage extends StatefulWidget {
  final String trainerId;
  final String trainerName;

  const TrainerDetailsPage({
    super.key,
    required this.trainerId,
    required this.trainerName,
  });

  @override
  State<TrainerDetailsPage> createState() => _TrainerDetailsPageState();
}

class _TrainerDetailsPageState extends State<TrainerDetailsPage> {
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = ApiService.getMembersForTrainer(widget.trainerId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trainerName),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.secondaryText,
      ),
      body: FutureBuilder<List<Member>>(
        future: _membersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No members assigned to this trainer.'));
          }

          final members = snapshot.data!;
          // We can reuse the same card layout from MembersView
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final bool isMembershipActive =
                  member.membershipEndDate.isAfter(DateTime.now());
              return Card(
                color: AppColors.surface,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.background,
                        child: Text(member.name[0],
                            style: const TextStyle(
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member.name,
                                style: const TextStyle(
                                    color: AppColors.secondaryText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                                'Expires: ${DateFormat.yMMMd().format(member.membershipEndDate)}',
                                style: TextStyle(
                                    color: AppColors.secondaryText
                                        .withOpacity(0.7))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.circle,
                          color: isMembershipActive
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          size: 12),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
