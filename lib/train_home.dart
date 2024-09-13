import 'dart:convert';

import 'package:fft/general_style.dart';
import 'package:fft/train_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'general_language.dart';
import 'train_data.dart';

class TrainPage extends StatefulWidget {
  final String l;

  const TrainPage({super.key, required this.l});

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  // Variabili
  List<Plan> plans = [];

  // Funzioni State
  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final loadedPlans = await loadPlans();
    setState(() {
      plans = loadedPlans;
    });
  }

  void _refreshAndSave(List<Plan> newPlans) {
    setState(() {
      plans = newPlans;
    });
    savePlans(plans: plans);
  }

  // Funzioni
  void _importPlan(TextEditingController importController) {
    try {
      final Map<String, dynamic> planMap = json.decode(importController.text);
      final importedPlan = Plan.fromJson(planMap);
      setState(() {
        plans.add(importedPlan);
      });
      _refreshAndSave(plans);
      Navigator.of(context).pop();
    } catch (e) {
      _failedImportDialog(e);
    }
  }

  void _addPlan() {
    plans.insert(0, Plan(name: languageMap[widget.l]?["New plan"] ?? ""));
    _refreshAndSave(plans);
  }

  void _switchPlans(int from, int to) {
    if (to > from) {
      to = to - 1;
    }
    final Plan item = plans.removeAt(from);
    plans.insert(to, item);
    _refreshAndSave(plans);
  }

  // Funzioni Dialogo
  void _importPlanDialog() {
    TextEditingController importController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[widget.l]?["Import plan"] ?? ""),
          content: TextField(
            controller: importController,
            decoration: InputDecoration(
              labelText: languageMap[widget.l]?["Paste plan data here"] ?? "",
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageMap[widget.l]?["Cancel"] ?? ""),
            ),
            TextButton(
              onPressed: () => _importPlan(importController),
              child: Text(languageMap[widget.l]?["Confirm"] ?? ""),
            ),
          ],
        );
      },
    );
  }

  void _failedImportDialog(e) {
    Navigator.of(context).pop();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(languageMap[widget.l]?["Error"] ?? ""),
            content: Text(
                "${languageMap[widget.l]?["Failed to import plan\n\nError:\n"] ?? ""}${e}"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Ok"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageMap[widget.l]?["Train"] ?? "",
          style: const TextStyle(
            color: AppColors.text1,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
              onPressed: () => _importPlanDialog(),
              icon: const Icon(Icons.download)),
          IconButton(onPressed: () => _addPlan(), icon: const Icon(Icons.add))
        ],
      ),
      body:Center(
          child: plans.isNotEmpty
              ? ReorderableListView.builder(
                  itemCount: plans.length,
                  itemBuilder: (context, planIndex) {
                    final plan = plans[planIndex];
                    return PlanElement(
                      key: ValueKey(plan.hashCode),
                      plans: plans,
                      planIndex: planIndex,
                      plan: plan,
                      refreshAndSave: (newPlans) => _refreshAndSave(newPlans),
                      l: widget.l,
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) =>
                      _switchPlans(oldIndex, newIndex),
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
                    Text(languageMap[widget.l]?["No plan available!"] ?? ""),
                    const Icon(
                      Icons.sentiment_very_satisfied,
                      size: 100,
                    ),
                    SizedBox(
                      width: 200,
                      child: Text(languageMap[widget.l]?[
                              "But don't worry, create one now by clicking on the plus at the top right!"] ??
                          ""),
                    ),
                  ],
                ),
        ),
    );
  }
}

class PlanElement extends StatelessWidget {
  final String l;
  final List<Plan> plans;
  final int planIndex;
  final Plan plan;
  final void Function(List<Plan>) refreshAndSave;

  const PlanElement(
      {super.key,
      required this.plans,
      required this.planIndex,
      required this.plan,
      required this.refreshAndSave,
      required this.l});

  // Funzioni
  void _removePlan(BuildContext context) {
    plans.removeAt(planIndex);
    refreshAndSave(plans);
    Navigator.of(context).pop();
  }

  void _startPlanPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlanPage(
                initialPlans: plans,
                planIndex: planIndex,
                l: l,
              )),
    ).then((updatedPlans) {
      if (updatedPlans != null) {
        refreshAndSave(updatedPlans as List<Plan>);
      }
    });
  }

  // Funzioni Dialogo
  void _removePlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[l]?["Confirm"] ?? ""),
          content: Text(
              '${languageMap[l]?["Are you sure you want to delete the plan:"] ?? ""} ${plans[planIndex].name}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                languageMap[l]?["Cancel"] ?? "",
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
            TextButton(
              onPressed: () => _removePlan(context),
              child: Text(
                languageMap[l]?["Delete"] ?? "",
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary,
      child: InkWell(
        onTap: () {
          _startPlanPage(context);
        },
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 0.0, bottom: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plans[planIndex].name,
                      style: const TextStyle(
                        fontSize: Constants.fontSize2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        plans[planIndex].workouts.take(10).length,
                        (index) => const Icon(Icons.fitness_center),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removePlanDialog(context),
                icon: const Icon(
                  Icons.delete,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
