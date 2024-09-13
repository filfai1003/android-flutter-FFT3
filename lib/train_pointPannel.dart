import 'package:flutter/material.dart';
import 'package:fft/general_style.dart';
import 'package:fft/train_data.dart';

import 'general_language.dart';


class RightPanelPage extends StatefulWidget {
  final String l;
  final List<Plan> plans;
  final List<BaseEx> baseExs;
  final String baseExName;
  final int planIndex;
  final int workoutIndex;
  final int exIndex;

  const RightPanelPage({
    super.key,
    required this.baseExName,
    required this.planIndex,
    required this.workoutIndex,
    required this.exIndex,
    required this.baseExs,
    required this.plans, required this.l,
  });

  @override
  _RightPanelPageState createState() => _RightPanelPageState();
}

class _RightPanelPageState extends State<RightPanelPage> {
  int _calculatedLoad = 0;
  int _calculatedPoint = 0;
  int _currentRepsInput = 0;
  int _currentKgInput = 0;
  int _baseExIndex = -1;
  BaseEx baseEx = BaseEx("");

  @override
  void initState() {
    baseEx = _findBaseEx(widget.baseExName);
    super.initState();
  }

  BaseEx _findBaseEx(String name) {
    for (BaseEx b in widget.baseExs) {
      if (b.name == name) {
        _baseExIndex = widget.baseExs.indexOf(b);
        return b;
      }
    }
    _baseExIndex = widget.baseExs.length;
    BaseEx b = BaseEx(name);
    widget.baseExs.add(b);
    saveBaseExs(baseExs: widget.baseExs);

    return b;
  }

  Future<void> _addAndOrderBaseEx(BaseEx baseEx) async {
    List<BaseEx> baseExs = await loadBaseExs();
    if (baseExs.isEmpty) {
      baseExs.add(baseEx);
    } else {
      int insertIndex = 0;
      for (int i = 0; i < baseExs.length; i++) {
        if (baseExs[i].muscle.muscle > baseEx.muscle.muscle) {
          insertIndex = i;
          break;
        } else if (baseExs[i].muscle.muscle == baseEx.muscle.muscle) {
          if (baseExs[i].name == baseEx.name){
            return;
          }
          if (baseExs[i].name.compareTo(baseEx.name) > 0) {
            insertIndex = i;
            break;
          } else {
            insertIndex = i + 1;
          }
        } else {
          insertIndex = i + 1;
        }
      }
      baseExs.insert(insertIndex, baseEx);
    }
    saveBaseExs(baseExs: baseExs);
  }





  void _saveBasex() {
    baseEx.maxPoint = _calculatedPoint;
    baseEx.maxPointKg = _currentKgInput;
    baseEx.maxPointReps = _currentRepsInput;
    widget.baseExs[_baseExIndex] = baseEx;
    setState(() {});
    Navigator.of(context).pop();
  }

  void _uploadDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[widget.l]?["Confirm"] ?? ""),
          content: Text(languageMap[widget
              .l]?["Are you sure you want to upload new data?"] ?? ""),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                languageMap[widget.l]?["Cancel"] ?? "",
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () => _saveBasex(),
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

  void _calculateLoad(int reps, int point) {
    setState(() {
      _calculatedLoad = (point / (1 + ((reps - 1) / 30))).round();
    });
  }

  void _calculatePoint() {
    setState(() {
      _calculatedPoint =
          (_currentKgInput * (1 + ((_currentRepsInput - 1) / 30))).round();
    });
  }

  void _goBackWithUpdatedPlans() {
    Navigator.pop(context, widget.baseExs);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBackWithUpdatedPlans();
        return true;
      },
      child: Drawer(
        child: Container(
          color: AppColors.primary,
          child: ListView(
            children: [
              AppBar(
                backgroundColor: AppColors.primary,
                title: Text(widget.baseExName),
                automaticallyImplyLeading: false,
              ),
              // "Your Maximum" Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(languageMap[widget.l]?["Current data"] ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Text(
                          '${languageMap[widget.l]?["Reps"] ?? ""}: ${baseEx
                              .maxPointReps}',
                          textAlign: TextAlign.center),
                    ),
                    Expanded(
                      child: Text(
                          '${languageMap[widget.l]?["Load"] ?? ""}: ${baseEx
                              .maxPointKg}',
                          textAlign: TextAlign.center),
                    ),
                    Expanded(
                      child: Text(
                          '${languageMap[widget.l]?["1RM"] ?? ""}: ${baseEx
                              .maxPoint}',
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // "Calculate Weight to Perform" Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    languageMap[widget.l]?["Calculate perform weight"] ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: languageMap[widget
                                .l]?["Reps to perform"] ?? "",
                            border: const OutlineInputBorder()),
                        onChanged: (value) {
                          final reps = int.tryParse(value) ?? 0;
                          _calculateLoad(reps, baseEx.maxPoint);
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                          "${languageMap[widget.l]?["Calculated Load:"] ??
                              ""}$_calculatedLoad",
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // "Upload Data" Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(languageMap[widget.l]?["Load data"] ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Reps',
                            // Consider adding this to languageMap if localization needed
                            border: OutlineInputBorder()),
                        onChanged: (value) {
                          _currentRepsInput = int.tryParse(value) ?? 0;
                          _calculatePoint();
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Kg',
                            // Consider adding this to languageMap if localization needed
                            border: OutlineInputBorder()),
                        onChanged: (value) {
                          _currentKgInput = int.tryParse(value) ?? 0;
                          _calculatePoint();
                        },
                      ),
                    ),
                    Expanded(
                      child: Text("1RM: $_calculatedPoint",
                          textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.upload, color: Colors.white),
                onPressed: () {
                  _uploadDataDialog(context);
                },
              ),
              // Exercise Description
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "${languageMap[widget.l]?["Exercise description:"] ??
                      ""}\n${baseEx.description}",
                  style:
                  const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  baseEx.description,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}