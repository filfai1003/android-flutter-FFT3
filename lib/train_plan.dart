import 'dart:convert';
import 'dart:core';

import 'package:fft/general_style.dart';
import 'package:fft/train_data.dart';
import 'package:fft/train_workoutModPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'general_language.dart';

class PlanPage extends StatefulWidget {
  final String l;
  final List<Plan> initialPlans;
  final int planIndex;

  const PlanPage(
      {super.key,
      required this.planIndex,
      required this.initialPlans,
      required this.l});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  void _goBackWithUpdatedPlans() {
    Navigator.pop(context, plans);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBackWithUpdatedPlans();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            plans[widget.planIndex].name,
            style: const TextStyle(
              color: AppColors.text1,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
                onPressed: () => _editPlanNameDialog(),
                icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: _shareCurrentPlan, icon: const Icon(Icons.share)),
            IconButton(
                onPressed: () => _addWorkout(), icon: const Icon(Icons.add))
          ],
        ),
        body: Center(
          child: workouts.isNotEmpty
              ? ReorderableListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, workoutIndex) {
                    final workout = workouts[workoutIndex];
                    return WorkoutElement(
                      key: ValueKey(workout.hashCode),
                      plans: plans,
                      planIndex: widget.planIndex,
                      workoutIndex: workoutIndex,
                      workout: workout,
                      refreshAndSave: _refreshAndSave,
                      l: widget.l,
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) =>
                      _switchWorkouts(oldIndex, newIndex),
                )
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    const Icon(Icons.sentiment_dissatisfied, size: 100),
                    Text(languageMap[widget.l]?["No workout available!"] ?? ""),
                    const Icon(Icons.sentiment_very_satisfied, size: 100),
                    SizedBox(
                      width: 200,
                      child: Text(languageMap[widget.l]?[
                              "But don't worry, create one now by clicking on the plus at the top right!"] ??
                          ""),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  List<Plan> plans = [];
  List<Workout> workouts = [];

  @override
  void initState() {
    super.initState();
    _refreshAndSave(widget.initialPlans);
  }

  void _refreshAndSave(List<Plan> newPlans) {
    setState(() {
      plans = newPlans;
      workouts = plans[widget.planIndex].workouts;
    });
    savePlans(plans: plans);
  }

  void _editPlanNameDialog() {
    TextEditingController nameController =
        TextEditingController(text: plans[widget.planIndex].name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[widget.l]?["Edit plan name"] ?? ""),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: languageMap[widget.l]?["Name"] ?? "",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(languageMap[widget.l]?["Cancel"] ?? ""),
            ),
            TextButton(
              onPressed: () => _editPlanName(nameController.text),
              child: Text(languageMap[widget.l]?["Confirm"] ?? ""),
            ),
          ],
        );
      },
    );
  }

  void _editPlanName(String name) {
    setState(() {
      plans[widget.planIndex].name = name;
    });
    Navigator.of(context).pop();
  }

  Future<void> _shareCurrentPlan() async {
    final Map<String, dynamic> currentPlanMap =
        plans[widget.planIndex].toJson();
    final String currentPlanJson = jsonEncode(currentPlanMap);
    Share.share(currentPlanJson);
  }

  void _addWorkout() {
    plans[widget.planIndex]
        .workouts
        .add(Workout(name: languageMap[widget.l]?["New workout"] ?? ""));
    _refreshAndSave(plans);
  }

  void _switchWorkouts(int from, int to) {
    if (to > from) {
      to -= 1;
    }
    final Workout item = plans[widget.planIndex].workouts.removeAt(from);
    plans[widget.planIndex].workouts.insert(to, item);
    _refreshAndSave(plans);
  }
}

class WorkoutElement extends StatelessWidget {
  final String l;
  final List<Plan> plans;
  final int planIndex;
  final int workoutIndex;
  final Workout workout;
  final void Function(List<Plan>) refreshAndSave;

  const WorkoutElement({
    super.key,
    required this.plans,
    required this.planIndex,
    required this.workoutIndex,
    required this.workout,
    required this.refreshAndSave,
    required this.l,
  });

  void _removeWorkoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[l]?["Delete workout"] ?? ""),
          content: Text(
              '${languageMap[l]?["Are you sure you want to delete the workout:"] ?? ""} ${workout.name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(languageMap[l]?["Cancel"] ?? "",
                  style: const TextStyle(color: AppColors.primary)),
            ),
            TextButton(
              onPressed: () => _removeWorkout(context),
              child: Text(languageMap[l]?["Delete"] ?? "",
                  style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _removeWorkout(BuildContext context) {
    plans[planIndex].workouts.removeAt(workoutIndex);
    refreshAndSave(plans);
    Navigator.of(context).pop();
  }

  void _startWorkoutPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ModPage(
              initialPlans: plans,
              planIndex: planIndex,
              workoutIndex: workoutIndex,
              l: l)),
    ).then((updatedPlans) {
      if (updatedPlans != null) {
        refreshAndSave(updatedPlans as List<Plan>);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary,
      child: InkWell(
        onTap: () => _startWorkoutPage(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workout.name,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Row(
                      children: List.generate(workout.exs.take(10).length,
                          (index) => const Icon(Icons.circle)),
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () => _removeWorkoutDialog(context),
                  icon: const Icon(Icons.delete, size: 25))
            ],
          ),
        ),
      ),
    );
  }
}
