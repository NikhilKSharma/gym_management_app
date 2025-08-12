import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymanager/src/config/app_colors.dart';
import 'package:gymanager/src/models/trainer_model.dart';
import 'package:gymanager/src/services/api_service.dart';

class TrainersView extends StatefulWidget {
  const TrainersView({super.key});

  @override
  State<TrainersView> createState() => _TrainersViewState();
}

class _TrainersViewState extends State<TrainersView> {
  late Future<List<Trainer>> _trainersFuture;

  @override
  void initState() {
    super.initState();
    _trainersFuture = ApiService.getTrainers();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trainer>>(
      future: _trainersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.accent));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No trainers found.'));
        }

        final trainers = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: trainers.length,
          itemBuilder: (context, index) {
            final trainer = trainers[index];
            return InkWell(
                // Wrap Card with InkWell
                onTap: () {
                  context.push('/trainer/${trainer.id}', extra: trainer.name);
                },
                child: Card(
                  color: AppColors.surface,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent,
                      child: Icon(
                        trainer.gender.toLowerCase() == 'male'
                            ? Icons.male
                            : Icons.female,
                        color: AppColors.surface,
                      ),
                    ),
                    title: Text(
                      trainer.name,
                      style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      trainer.gender,
                      style: TextStyle(
                          color: AppColors.secondaryText.withOpacity(0.7)),
                    ),
                  ),
                ));
          },
        );
      },
    );
  }
}
