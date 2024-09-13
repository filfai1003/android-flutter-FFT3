import 'package:fft/general_style.dart';
import 'package:fft/train_data.dart';
import 'package:flutter/material.dart';

import 'general_language.dart';

class BaseExSelectionPage extends StatefulWidget {
  final String l;
  final List<Plan> plans;
  final int planIndex;
  final int workoutIndex;
  final int exIndex;

  const BaseExSelectionPage({
    super.key,
    required this.plans,
    required this.planIndex,
    required this.workoutIndex,
    required this.exIndex,
    required this.l,
  });

  @override
  State<BaseExSelectionPage> createState() => _BaseExSelectionPageState();
}

class _BaseExSelectionPageState extends State<BaseExSelectionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<BaseEx> baseExs = [];
  List<BaseEx> searchList = [];
  String key = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadBaseExs();
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
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
          backgroundColor: AppColors.primary,
          title: Text(languageMap[widget.l]?["Select exercise"] ?? ""),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteAllDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addBaseExBaseDialog(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: languageMap[widget.l]?["Push"] ?? ""),
              Tab(text: languageMap[widget.l]?["Pull"] ?? ""),
              Tab(text: languageMap[widget.l]?["Legs"] ?? ""),
              Tab(text: languageMap[widget.l]?["Arms"] ?? ""),
              Tab(text: languageMap[widget.l]?["Other"] ?? ""),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    key = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: languageMap[widget.l]?["Search"] ?? "",
                  suffixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildExerciseList(0),
                  _buildExerciseList(2),
                  _buildExerciseList(3),
                  _buildExerciseList(1),
                  _buildExerciseList(4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goBackWithUpdatedPlans() {
    Navigator.pop(context, widget.plans);
  }

  Future<void> _loadBaseExs() async {
    List<BaseEx> loadedBaseExs = await loadBaseExs();
    if (loadedBaseExs.isEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(languageMap[widget.l]?["No exercises available!"] ?? ""),
            content: Text(languageMap[widget.l]?["You don't have any exercises, do you want us to automatically add our selection of exercises?"] ?? ""),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'No',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              TextButton(
                onPressed: () {
                  loadedBaseExs = languageBaseExMap[widget.l] ?? [];
                  saveBaseExs(baseExs: loadedBaseExs);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          );
        },
      );
    }
    setState(() {
      baseExs = loadedBaseExs;
    });
  }

  void _refreshAndSave(List<BaseEx> newBaseExs){
    setState(() {
      baseExs = newBaseExs;
    });
    saveBaseExs(baseExs: baseExs);
  }

  List<BaseEx> _getExercises(int ppl, List<BaseEx> exs) {
    List<BaseEx> ret = [];
    for (BaseEx baseEx in exs) {
      if (ppl == 0) {
        if (baseEx.muscle.muscle > 0 && baseEx.muscle.muscle <= 6) {
          ret.add(baseEx);
        }
      } else if (ppl == 1) {
        if (baseEx.muscle.muscle > 6 && baseEx.muscle.muscle <= 10) {
          ret.add(baseEx);
        }
      } else if (ppl == 2) {
        if (baseEx.muscle.muscle > 10 && baseEx.muscle.muscle <= 16) {
          ret.add(baseEx);
        }
      } else if (ppl == 3) {
        if (baseEx.muscle.muscle > 16 && baseEx.muscle.muscle <= 21) {
          ret.add(baseEx);
        }
      } else {
        if (baseEx.muscle.muscle == 0 || baseEx.muscle.muscle == 22) {
          ret.add(baseEx);
        }
      }
    }
    searchList = ret;
    return ret;
  }

  List<BaseEx> _filterList(String keyWorld, int ppl, List<BaseEx> exs) {
    List<BaseEx> exercises = _getExercises(ppl, exs);

    if (keyWorld.isEmpty) {
      searchList = exercises;
    } else {
      searchList = exercises
          .where(((ex) => (ex.name
          .toLowerCase()
          .contains(keyWorld.toLowerCase()) ||
          ex.muscle.name.toLowerCase().contains(keyWorld.toLowerCase()))))
          .toList();
    }
    return searchList;
  }

  void _selectBaseEx(BaseEx baseEx){
    widget.plans[widget.planIndex].workouts[widget.workoutIndex].exs[widget.exIndex].baseEx = baseEx.name;
    savePlans(plans: widget.plans);
  }

  Widget _buildExerciseList(int ppl) {
    List<BaseEx> searchList = _filterList(key, ppl, baseExs);

    return ListView.separated(
      itemCount: searchList.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(searchList[index].name),
          subtitle: Text(languageMuscleMap[widget.l]?[searchList[index].muscle.muscle] ?? "?"),
          onTap: () {
            _selectBaseEx(searchList[index]);
            Navigator.pop(context, widget.plans);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeBaseExDialog(index, ppl),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  void _removeBaseExDialog(int searchListIndex, int ppl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[widget.l]?["Confirm"] ?? ""),
          content: Text(languageMap[widget.l]?["Are you sure you want to delete the exercise?"] ?? ""),
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
              onPressed: () => _removeBaseEx(searchListIndex, ppl),
              child: Text(
                languageMap[widget.l]?["Delete"] ?? "",
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _removeBaseEx(int searchListIndex, int ppl){
    searchList = _filterList(key, ppl, baseExs);
    baseExs.remove(searchList[searchListIndex]);
    _refreshAndSave(baseExs);
    Navigator.pop(context);
  }

  void _deleteAllDialog() {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[widget.l]?["Delete all"] ?? ""),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: languageMap[widget.l]?["Type \"Delete All\" to confirm"] ?? "",
                ),
              ),
            ],
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
                if (textController.text.trim().toLowerCase() == "delete all") {
                  _refreshAndSave([]);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                languageMap[widget.l]?["Confirm"] ?? "",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addBaseExBaseDialog() {
    TextEditingController nameController = TextEditingController();
    int selectedMuscle = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text(languageMap[widget.l]?["Add an exercise"] ?? ""),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: languageMap[widget.l]?["Name"] ?? "",
                    ),
                  ),
                  DropdownButton<int>(
                    value: selectedMuscle,
                    items: muscles.map((Muscle muscle) {
                      return DropdownMenuItem<int>(
                        value: muscle.muscle,
                        child: Text(languageMuscleMap[widget.l]?[muscle.muscle] ?? "?"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedMuscle = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context). pop();
                  },
                  child: Text(languageMap[widget.l]?["Cancel"] ?? ""),
                ),
                TextButton(
                  onPressed: () {
                    _addBaseEx(nameController.text, selectedMuscle);
                    Navigator.of(context).pop();
                  },
                  child: Text(languageMap[widget.l]?["Confirm"] ?? ""),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addBaseEx(String name, int muscle){
    BaseEx baseEx = BaseEx(name);
    baseEx.muscle = muscles[0];
    for (Muscle m in muscles){
      if (m.muscle == muscle){
        baseEx.muscle = m;
      }
    }
    _addAndOrderBaseEx(baseEx);
  }

  void _addAndOrderBaseEx(BaseEx baseEx) {
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
    _refreshAndSave(baseExs);
  }
}
