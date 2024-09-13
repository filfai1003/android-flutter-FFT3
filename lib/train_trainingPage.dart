import 'dart:async';

import 'package:fft/general_style.dart';
import 'package:fft/train_data.dart';
import 'package:fft/train_pointPannel.dart';
import 'package:flutter/material.dart';

import 'general_language.dart';


class TrainingPage extends StatefulWidget {
  final String l;
  final List<Plan> initialPlans;
  final int planIndex;
  final int workoutIndex;

  const TrainingPage(
      {super.key, required this.planIndex, required this.workoutIndex, required this.initialPlans, required this.l});

  @override
  State<TrainingPage> createState() => _TrainPageState();
}


class _TrainPageState extends State<TrainingPage> {

  List<Plan> plans = [];
  Ex ex = Ex();
  BaseEx baseEx = BaseEx("");
  int _exIndex = 0;
  int _wkLenght = 0;
  TextEditingController _notesController = TextEditingController();

  List<BaseEx> baseExs = [];

  double _timerProgress = 1.0;
  Timer? _restTimer;
  double _secondsRemaining = 0;

  @override
  void initState() {
    _loadEx(_exIndex);
    super.initState();
  }

  Future<void> _loadEx(int index) async {
    baseExs = await loadBaseExs();
    plans = widget.initialPlans;
    ex = Ex();
    if (plans[widget.planIndex].workouts[widget.workoutIndex].exs.isNotEmpty) {
      ex = plans[widget.planIndex].workouts[widget.workoutIndex].exs[index];
    }
    for (BaseEx b in baseExs){
      if(b.name == ex.baseEx){
        baseEx = b;
        break;
      }
    }
    _exIndex = index;
    _wkLenght = plans[widget.planIndex].workouts[widget.workoutIndex].exs.length;
    _notesController = TextEditingController(text: ex.notes);
    setState(() {});
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  void _startRestTimer() {
    _secondsRemaining = ex.rest.toDouble();
    _timerProgress = 0.0;
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (_secondsRemaining.round() >= 1) {
        setState(() {
          _secondsRemaining = _secondsRemaining - 0.1;
          _timerProgress = 1 - _secondsRemaining / ex.rest;
        });
      } else {
        _restTimer?.cancel();
      }
    });
  }

  void _saveNotes(String notes){
    plans[widget.planIndex].workouts[widget.workoutIndex].exs[_exIndex].notes = notes;
    savePlans(plans: plans);
  }

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
          title: Text(widget.initialPlans[widget.planIndex].workouts[widget.workoutIndex].name),
          backgroundColor: AppColors.primary,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        endDrawer: RightPanelPage(
          baseExName: ex.baseEx,
          planIndex: widget.planIndex,
          workoutIndex: widget.workoutIndex,
          exIndex: widget.workoutIndex,
          baseExs: baseExs,
          plans: plans,
          l: widget.l
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  ex.baseEx,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                ),
                                Text(
                                  languageMuscleMap[widget.l]?[baseEx.muscle.muscle] ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "${_secondsRemaining.toStringAsFixed(0)} sec",
                                style: const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                  onPressed: _startRestTimer,
                                  icon: const Icon(Icons.timer, color: Colors.white)),
                              const SizedBox(width: 4),
                              Text(
                                "${ex.rest} sec",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    LinearProgressIndicator(
                      value: _timerProgress,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Set & reps:"),
                              Text(ex.setAndReps),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("TUT:"),
                              Text(ex.tut.toString()),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: languageMap[widget.l]?["Enter notes here"] ?? "",
                        ),
                        maxLines: null,
                        onChanged: (value) => _saveNotes(value),
                      ),
                    ),
                  ],
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FloatingActionButton(
                      onPressed: () => _loadEx(_exIndex-1),
                      backgroundColor: AppColors.primary,
                      heroTag: 'prevExButton',
                      child: const Icon(Icons.arrow_left), // Unique tag for this button
                    ),
                    Row(
                      children: List.generate(
                        _wkLenght,
                            (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < _exIndex + 1 ? AppColors.primary : Colors.grey[300],
                            ),
                          );
                        },
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () => _loadEx(_exIndex+1),
                      backgroundColor: AppColors.primary,
                      heroTag: 'nextExButton',
                      child: const Icon(Icons.arrow_right),
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
}
