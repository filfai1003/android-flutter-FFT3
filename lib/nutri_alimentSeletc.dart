import 'package:flutter/material.dart';

import 'general_language.dart';
import 'general_style.dart';
import 'nutri_data.dart';

class AlimentSelectionPage extends StatefulWidget {
  final String l;
  final List<NutriDay> nutridays;
  final int nutriDayIndex;
  final int mealIndex;
  final int portionIndex;
  final bool settings;

  const AlimentSelectionPage(
      {super.key,
      required this.l,
      required this.nutridays,
      required this.nutriDayIndex,
      required this.mealIndex,
      required this.portionIndex,
      required this.settings});

  @override
  State<AlimentSelectionPage> createState() => _AlimentSelectionPageState();
}

class _AlimentSelectionPageState extends State<AlimentSelectionPage>
    with TickerProviderStateMixin {
  List<Aliment> searchList = [];
  late TabController _tabController;
  String key = "";
  List<Aliment> aliments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadAliments();
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAliments() async {
    List<Aliment> loadedBaseExs = await loadAliments();
    if (loadedBaseExs.isEmpty) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(languageMap[widget.l]?["No aliments available!"] ?? ""),
            content: Text(languageMap[widget.l]?[
                    "You don't have any exercises, do you want us to automatically add our selection of aliments?"] ??
                ""),
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
                  loadedBaseExs = languageAlimentMap[widget.l] ?? [];
                  saveAliments(aliments: loadedBaseExs);
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
      aliments = loadedBaseExs;
    });
  }

  void _refreshAndSave(List<Aliment> newAliments) {
    setState(() {
      aliments = newAliments;
    });
    saveAliments(aliments: aliments);
  }

  List<Aliment> _getAliments(int type, List<Aliment> aliments) {
    List<Aliment> ret = [];
    for (Aliment aliment in aliments) {
      if (type == 0) {
        if (aliment.type == 0) {
          ret.add(aliment);
        }
      } else if (type == 1) {
        if (aliment.type == 1) {
          ret.add(aliment);
        }
      } else if (type == 2) {
        if (aliment.type == 2) {
          ret.add(aliment);
        }
      } else {
        if (aliment.type != 0 && aliment.type != 1 && aliment.type != 2) {
          ret.add(aliment);
        }
      }
    }
    searchList = ret;
    return ret;
  }

  List<Aliment> _filterList(String keyWorld, int ppl, List<Aliment> exs) {
    List<Aliment> aliment = _getAliments(ppl, exs);

    if (keyWorld.isEmpty) {
      searchList = aliment;
    } else {
      searchList = aliment
          .where(((al) =>
              (al.name.toLowerCase().contains(keyWorld.toLowerCase()))))
          .toList();
    }
    return searchList;
  }

  void _selectBaseEx(Aliment aliment) {
    widget.nutridays[widget.nutriDayIndex].meals[widget.mealIndex]
        .portions[widget.portionIndex].aliment = aliment;
    if (widget.settings) {
      saveNutriDay(widget.nutridays[0]);
    } else {
      saveNutridays(nutridays: widget.nutridays);
    }
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
                  labelText: languageMap[widget.l]
                          ?["Type \"Delete All\" to confirm"] ??
                      "",
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

  void _addAlimentDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController kcalController = TextEditingController();
    TextEditingController protController = TextEditingController();
    TextEditingController carbController = TextEditingController();
    TextEditingController fatsController = TextEditingController();
    TextEditingController saltController = TextEditingController();

    int selectedType = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: Text(languageMap[widget.l]?["Add an exercise"] ?? ""),
              content: SingleChildScrollView( // Wrap with SingleChildScrollView
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: languageMap[widget.l]?["Name"] ?? "",
                      ),
                    ),
                    DropdownButton<int>(
                      value: selectedType,
                      items: types.entries.map((MapEntry<int, String> entry) {
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(languageMap[widget.l]?[entry.value] ?? "?"),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    TextField(
                      controller: kcalController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: languageMap[widget.l]?["Calories"] ?? "",
                      ),
                    ),
                    TextField(
                      controller: protController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: languageMap[widget.l]?["Proteins"] ?? "",
                      ),
                    ),
                    TextField(
                      controller: carbController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: languageMap[widget.l]?["Carbs"] ?? "",
                      ),
                    ),
                    TextField(
                      controller: fatsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: languageMap[widget.l]?["Fats"] ?? "",
                      ),
                    ),
                    TextField(
                      controller: saltController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: languageMap[widget.l]?["Salt"] ?? "",
                      ),
                    ),
                  ],
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
                    _addAliment(
                      nameController.text,
                      int.parse(kcalController.text),
                      int.parse(protController.text),
                      int.parse(carbController.text),
                      int.parse(fatsController.text),
                      int.parse(saltController.text),
                      selectedType,
                    );
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

  void _addAliment(String name, int kcal, int proteins, int carbs, int fats, int salt, int type) {
    Aliment aliment = Aliment(name, NutriScore(kcal: kcal, protein: proteins, carbs: carbs, fats: fats, salt: salt));
    aliment.type = type;
    _addAndOrderAliment(aliment);
  }
  void _addAndOrderAliment(Aliment aliment){
    if (aliments.isEmpty) {
      aliments.add(aliment);
    } else {
      int insertIndex = 0;
      for (int i = 0; i < aliments.length; i++) {
        if (aliments[i].type > aliment.type) {
          insertIndex = i;
          break;
        } else if (aliments[i].type == aliment.type) {
          if (aliments[i].name == aliment.name){
            return;
          }
          if (aliments[i].name.compareTo(aliment.name) > 0) {
            insertIndex = i;
            break;
          } else {
            insertIndex = i + 1;
          }
        } else {
          insertIndex = i + 1;
        }
      }
      aliments.insert(insertIndex, aliment);
    }
    _refreshAndSave(aliments);
  }

  void _removeAlimentDialog(int index, int type) {
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
              onPressed: () => _removeAliment(index, type),
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
  void _removeAliment(int searchListIndex, int type){
    searchList = _filterList(key, type, aliments);
    aliments.remove(searchList[searchListIndex]);
    _refreshAndSave(aliments);
    Navigator.pop(context);
  }

  Widget _buildAlimentsList(int type) {
    List<Aliment> searchList = _filterList(key, type, aliments);

    return ListView.separated(
      itemCount: searchList.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: Text(searchList[index].name),
          subtitle: Text(
              "${languageMap[widget.l]?["Calories"]}: ${searchList[index].nutriScore.kcal}, ${languageMap[widget.l]?["Proteins"]}: ${searchList[index].nutriScore.protein}, ${languageMap[widget.l]?["Carbs"]}: ${searchList[index].nutriScore.carbs}, ${languageMap[widget.l]?["Fats"]}: ${searchList[index].nutriScore.fats}, ${languageMap[widget.l]?["Salt"]}: ${searchList[index].nutriScore.salt}"),
          onTap: () {
            _selectBaseEx(searchList[index]);
            Navigator.pop(context, widget.nutridays);
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeAlimentDialog(index, type),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  void _goBackWithUpdatedPlans() {
    Navigator.pop(context, widget.nutridays);
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
          title: Text(languageMap[widget.l]?["Select aliment"] ?? ""),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteAllDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addAlimentDialog(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: languageMap[widget.l]?["Proteins"] ?? ""),
              Tab(text: languageMap[widget.l]?["Carbs"] ?? ""),
              Tab(text: languageMap[widget.l]?["Fats"] ?? ""),
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
                  _buildAlimentsList(0),
                  _buildAlimentsList(1),
                  _buildAlimentsList(2),
                  _buildAlimentsList(3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
