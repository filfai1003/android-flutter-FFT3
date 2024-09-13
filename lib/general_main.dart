import 'package:fft/general_style.dart';
import 'package:fft/nutri_home.dart';
import 'package:fft/train_data.dart';
import 'package:fft/train_home.dart';
import 'package:fft/train_trainingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';

import 'general_data.dart';
import 'general_language.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentLanguage = "en";
  Workout nextWorkout = Workout(name: "None");
  List<int> nextWorkoutIndex = [-1, -1];
  List<Plan> plans = [];

  @override
  void initState() {
    _initialisation();
    super.initState();
  }

  void _initialisation() async {
    plans = await loadPlans();
    nextWorkoutIndex = await loadNextWorkout();
    if (nextWorkoutIndex != [-1, -1]) {
      nextWorkout = plans[nextWorkoutIndex[0]].workouts[nextWorkoutIndex[1]];
    }

    loadLanguage().then((language) {
      setState(() {
        if (language == 'Français') {
          currentLanguage = 'fr';
        } else if (language == 'Italiano') {
          currentLanguage = 'it';
        } else if (language == 'Español') {
          currentLanguage = 'es';
        }
      });
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setNavigationBarColor(AppColors.primary);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FilFai Training",
          style: TextStyle(
              color: AppColors.text1,
              fontSize: Constants.fontSize1,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
              onPressed: () => _showLanguageSelectionDialog(context),
              icon: const Icon(
                Icons.language,
                size: Constants.iconSize2,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Constants.paddingValue),
              child: Column(
                children: [
                  Text(
                    languageMap[currentLanguage]?["Next Workout"] ?? "",
                    style: const TextStyle(
                        color: AppColors.text1, fontSize: Constants.fontSize3),
                  ),
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(Constants.borderRadiusValue1),
                      color: AppColors.background2,
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => _startTrainingPage(),
                          child: Container(
                            padding:
                                const EdgeInsets.all(Constants.paddingValue),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  Constants.borderRadiusValue1),
                              color: AppColors.primary,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nextWorkout.name,
                                  style: const TextStyle(
                                      fontSize: Constants.fontSize2,
                                      color: AppColors.text3,
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_right,
                                  size: Constants.iconSize2,
                                  color: AppColors.text3,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: Constants.paddingValue * 1.5),
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(
                                  nextWorkout.exs.length,
                                  (index) {
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  Constants.paddingValue),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${index + 1} ${nextWorkout.exs[index].baseEx}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: null,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  nextWorkout.exs[index].setAndReps,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (index != nextWorkout.exs.length - 1)
                                          const Divider(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primary),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () => _startTrainPage(),
                          icon: const Icon(Icons.fitness_center,),
                          iconSize: 100,
                        ),
                        SizedBox(
                          child: Text(
                            textAlign: TextAlign.center,
                            languageMap[currentLanguage]?["Train"] ?? "",
                            style: const TextStyle(
                                fontSize: Constants.fontSize2,
                                fontWeight: FontWeight.bold,
                                color: AppColors.text3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primary),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () => _startNutriPage(),
                          icon: const Icon(Icons.apple),
                          iconSize: 100,
                        ),
                        SizedBox(
                          child: Text(
                            languageMap[currentLanguage]?["Nutrition"] ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: Constants.fontSize2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primary),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {}, // TODO Avvia ProgressPage
                          icon: const Icon(Icons.trending_up),
                          iconSize: 100,
                        ),
                        SizedBox(
                          child: Text(
                            languageMap[currentLanguage]?["Progress"] ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: Constants.fontSize2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primary),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {}, // TODO Avvia ProgressPage
                          icon: const Icon(Icons.abc),
                          iconSize: 100,
                        ),
                        SizedBox(
                          child: Text(
                            languageMap[currentLanguage]?["Posing"] ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: Constants.fontSize2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primary),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {}, // TODO Avvia ProgressPage
                          icon: const Icon(Icons.calendar_today),
                          iconSize: 100,
                        ),
                        SizedBox(
                          child: Text(
                            languageMap[currentLanguage]?["Calendar"] ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: Constants.fontSize2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 150,
                    height: 180,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.primary),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {}, // TODO Avvia ProgressPage
                          icon: const Icon(Icons.star),
                          iconSize: 100,
                        ),
                        SizedBox(
                          child: Text(
                            languageMap[currentLanguage]?["Record"] ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: Constants.fontSize2,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            // TODO inserire sezione calendario che mostra i giorni della settimana  in cui si e' andati, con bottone per sezione calendario
          ],
        ),
      ),
    );
  }

  void _startTrainingPage() {
    if (plans[nextWorkoutIndex[0]] == null ||
        plans[nextWorkoutIndex[0]].workouts == null ||
        plans[nextWorkoutIndex[0]].workouts.length <= nextWorkoutIndex[1]) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingPage(
            planIndex: nextWorkoutIndex[0],
            workoutIndex: nextWorkoutIndex[1],
            initialPlans: plans,
            l: currentLanguage),
      ),
    ).then((updatedPlans) {
      if (nextWorkoutIndex[1] <
          plans[nextWorkoutIndex[0]].workouts.length - 1) {
        nextWorkoutIndex[1] = nextWorkoutIndex[1] + 1;
      } else {
        nextWorkoutIndex[1] = 0;
      }
      saveNextWorkout(indices: nextWorkoutIndex);
      if (updatedPlans != null) {
        _initialisation();
      }
    });
  }
  void _startTrainPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TrainPage(l: currentLanguage)),
    ).then((value) => setState(() {
      _initialisation();
    }));
  }
  void _startNutriPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              NutriPage(l: currentLanguage)),
    ).then((value) => setState(() {
      _initialisation();
    }));
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[currentLanguage]?["Choose a language"] ?? "",),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('English'),
                  onTap: () {
                    saveLanguage(language: 'English');
                    currentLanguage = 'en';
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Français'),
                  onTap: () {
                    saveLanguage(language: 'Français');
                    currentLanguage = 'fr';
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Italiano'),
                  onTap: () {
                    saveLanguage(language: 'Italiano');
                    currentLanguage = 'it';
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Español'),
                  onTap: () {
                    saveLanguage(language: 'Español');
                    currentLanguage = 'es';
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
