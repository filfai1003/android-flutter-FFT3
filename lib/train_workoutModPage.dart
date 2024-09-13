import 'package:fft/general_style.dart';
import 'package:fft/train_baseExSelect.dart';
import 'package:fft/train_data.dart';
import 'package:fft/train_trainingPage.dart';
import 'package:flutter/material.dart';

import 'general_language.dart';

class ModPage extends StatefulWidget {
  final String l;
  final List<Plan> initialPlans;
  final int planIndex;
  final int workoutIndex;

  const ModPage(
      {super.key,
      required this.initialPlans,
      required this.planIndex,
      required this.workoutIndex, required this.l});

  @override
  State<ModPage> createState() => _ModPageState();
}

class _ModPageState extends State<ModPage> {

  void _goBackWithUpdatedPlans() {
    Navigator.pop(context, plans);
  }

  @override
  Widget build(BuildContext context) {
    Workout workout = plans[widget.planIndex].workouts[widget.workoutIndex];

    return WillPopScope(
      onWillPop: () async {
        _goBackWithUpdatedPlans();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            workout.name,
            style: const TextStyle(
              color: AppColors.text1,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
                onPressed: () => _editWorkoutName(),
                icon: const Icon(Icons.edit)),
            IconButton(onPressed: () => _addEx(), icon: const Icon(Icons.add))
          ],
        ),
        body: Center(
            child: exs.isNotEmpty
                ? ReorderableListView.builder(
                    itemCount: exs.length,
                    itemBuilder: (context, exIndex) => ExElement(
                      key: ValueKey(exs[exIndex].hashCode),
                      initialPlans: plans,
                      planIndex: widget.planIndex,
                      workoutIndex: widget.workoutIndex,
                      exIndex: exIndex,
                      refreshAndSave: (plans) => _refreshAndSave(plans), l: widget.l,
                    ),
                    onReorder: (int oldIndex, int newIndex) =>
                        _switchWorkouts(oldIndex, newIndex),
                  )
                : Column(
                    children: [
                      const SizedBox(
                        width: 10,
                        height: 10,
                      ),
                      const Icon(
                        Icons.sentiment_dissatisfied,
                        size: 100,
                      ),
                      Text(languageMap[widget.l]?["No exercises available!"] ?? ""),
                      const Icon(
                        Icons.sentiment_very_satisfied,
                        size: 100,
                      ),
                      SizedBox(
                        width: 200,
                        child: Text(languageMap[widget.l]?["But don't worry, create one now by clicking on the plus at the top right!"] ?? ""),
                      ),
                    ],
                  ),
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _startTrainingPage(),
          backgroundColor: AppColors.primary,
          child: const Icon(
            Icons.arrow_right,
            size: 25,
          ),
        ),
      ),
    );
  }

  List<Plan> plans = [];
  List<Ex> exs = [];

  @override
  void initState() {
    super.initState();
    _refreshAndSave(widget.initialPlans);
  }

  void _refreshAndSave(List<Plan> newPlans) {
    setState(() {
      plans = newPlans;
      exs = plans[widget.planIndex].workouts[widget.workoutIndex].exs;
    });
    savePlans(plans: plans);
  }


  void _editWorkoutName() {
    TextEditingController nameController = TextEditingController(text: plans[widget.planIndex].workouts[widget.workoutIndex].name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[widget.l]?["Edit workout name"] ?? ""),
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
              onPressed: () {
                setState(() {
                  plans[widget.planIndex].workouts[widget.workoutIndex].name = nameController.text.toString();
                });
                _refreshAndSave(plans);
                Navigator.of(context).pop();
              },
              child: Text(languageMap[widget.l]?["Confirm"] ?? ""),
            ),
          ],
        );
      },
    );
  }

  void _addEx() {
    plans[widget.planIndex].workouts[widget.workoutIndex].exs.add(Ex());
    _refreshAndSave(plans);
  }

  void _startTrainingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingPage(
          planIndex: widget.planIndex,
          workoutIndex: widget.workoutIndex,
          initialPlans: plans,
          l: widget.l
        ),
      ),
    ).then((updatedPlans) {
      if (updatedPlans != null) {
        _refreshAndSave(updatedPlans as List<Plan>);
      }
    });
    List<int> nextWorkoutIndex = [widget.planIndex,0];
    if (widget.workoutIndex < plans[widget.planIndex].workouts.length-1){
      nextWorkoutIndex[1] = widget.workoutIndex+1;
    }
    saveNextWorkout(indices: nextWorkoutIndex);
  }

  void _switchWorkouts(int from, int to) {
    if (to > from) {
      to -= 1;
    }
    final Ex item = plans[widget.planIndex]
        .workouts[widget.workoutIndex]
        .exs
        .removeAt(from);
    plans[widget.planIndex].workouts[widget.workoutIndex].exs.insert(to, item);
    _refreshAndSave(plans);
  }
}

class ExElement extends StatefulWidget {
  final String l;
  final List<Plan> initialPlans;
  final int planIndex;
  final int workoutIndex;
  final int exIndex;
  final Function(List<Plan>) refreshAndSave;

  const ExElement({
    super.key,
    required this.initialPlans,
    required this.planIndex,
    required this.workoutIndex,
    required this.exIndex,
    required this.refreshAndSave, required this.l,
  });

  @override
  _ExElementState createState() => _ExElementState();
}

class _ExElementState extends State<ExElement> {
  Future<void> _removeExDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[widget.l]?["Confirm"] ?? ""),
          content: Text(
              '${languageMap[widget.l]?["Are you sure you want to delete the exercise?"] ?? ""} ${plans[widget.planIndex].workouts[widget.workoutIndex].exs[widget.exIndex].baseEx}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context). pop();
              },
              child: Text(
                languageMap[widget.l]?["Cancel"] ?? "",
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () => _removeEx(context),
              child: Text(
                languageMap[widget.l]?["Confirm"] ?? "",
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeEx(BuildContext context) {
    plans[widget.planIndex]
        .workouts[widget.workoutIndex]
        .exs
        .removeAt(widget.exIndex);
    widget.refreshAndSave(plans);
    Navigator.of(context).pop();
  }

  List<Plan> plans = [];
  Ex ex = Ex();

  @override
  void initState() {
    super.initState();
    _refreshAndSave(widget.initialPlans);
  }

  void _refreshAndSave(List<Plan> newPlans) {
    setState(() {
      plans = newPlans;
      ex = plans[widget.planIndex]
          .workouts[widget.workoutIndex]
          .exs[widget.exIndex];
    });
    savePlans(plans: plans);
  }

  void _saveEx(int rst, String value) {
    if (rst == 0) {
      plans[widget.planIndex]
          .workouts[widget.workoutIndex]
          .exs[widget.exIndex]
          .rest = int.tryParse(value)!;
    } else if (rst == 1) {
      plans[widget.planIndex]
          .workouts[widget.workoutIndex]
          .exs[widget.exIndex]
          .setAndReps = value;
    } else {
      plans[widget.planIndex]
          .workouts[widget.workoutIndex]
          .exs[widget.exIndex]
          .tut = int.tryParse(value)!;
    }
    savePlans(plans: plans);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 3,
                    child: TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BaseExSelectionPage(
                                  plans: plans,
                                  planIndex: widget.planIndex,
                                  workoutIndex: widget.workoutIndex,
                                  exIndex: widget.exIndex,
                                  l: widget.l
                              )),
                        ).then((updatedPlans) {
                          if (updatedPlans != null) {
                            _refreshAndSave(updatedPlans as List<Plan>);
                          }
                        });
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: AppColors.secondary,
                      ),
                      child: Text(
                        ex.baseEx.isEmpty ? (languageMap[widget.l]?["Select exercise"] ?? "") : ex.baseEx,
                        style: const TextStyle(color: Colors.black, fontSize: 17),
                      ),
                    )
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: ex.rest.toString(),
                    decoration: InputDecoration(labelText: languageMap[widget.l]?["Rest"] ?? ""),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _saveEx(0, value),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: ex.setAndReps,
                    decoration: InputDecoration(labelText: languageMap[widget.l]?["Sets and reps"] ?? ""),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onChanged: (value) => _saveEx(1, value),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: ex.tut.toString(),
                    decoration: InputDecoration(labelText: languageMap[widget.l]?["TUT"] ?? ""),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _saveEx(2, value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _removeExDialog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
