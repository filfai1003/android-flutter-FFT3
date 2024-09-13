import 'package:fft/general_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'general_language.dart';
import 'general_style.dart';
import 'nutri_data.dart';
import 'nutri_meal.dart';
import 'nutri_settings.dart';

class NutriPage extends StatefulWidget {
  final String l;

  const NutriPage({super.key, required this.l});

  @override
  State<NutriPage> createState() => _NutriPageState();
}

class _NutriPageState extends State<NutriPage> with TickerProviderStateMixin {
  List<NutriDay> nutriDays = [];
  int currentIndex = 0;
  late NutriDay baseNutriday;
  late AnimationController progressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late AnimationController progressController1 = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late AnimationController progressController2 = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late AnimationController progressController3 = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();
    _init();
  }
  @override
  void dispose() {
    progressController.dispose();
    progressController1.dispose();
    progressController2.dispose();
    progressController3.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    nutriDays = await loadNutridays();
    baseNutriday = await loadNutriDay(dateTimeToDay(DateTime.now()));
    await _loadNutriDays(dateTimeToDay(DateTime.now()));
  }

  Future<void> _loadNutriDays(Day day) async {
    int i = nutriDays.indexWhere(
        (nd) => dayToDateTime(nd.day).isAtSameMomentAs(dayToDateTime(day)));

    if (i == -1) {
      currentIndex = await insertNutriDayOrdered(NutriDay(
          day,
          baseNutriday.nutriScoreTheoric,
          baseNutriday.nutriScoreActual,
          baseNutriday.meals));
      setState(() {});
    } else {
      currentIndex = i;
      setState(() {});
    }
  }
  Future<int> insertNutriDayOrdered(NutriDay newNutriDay) async {
    int index = nutriDays.indexWhere(
        (nd) => dayToDateTime(nd.day).isBefore(dayToDateTime(newNutriDay.day)));
    if (index == -1) {
      index = nutriDays.length;
      nutriDays.add(newNutriDay);
    } else {
      nutriDays.insert(index, newNutriDay);
    }
    saveNutridays(nutridays: nutriDays);
    return index;
  }

  void _startNutriSettingsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NutriSettingsPage(
                l: widget.l,
              )),
    ).then((value) async {
      baseNutriday = value[0];
      if (value[1]) {
        nutriDays = [];
        await _loadNutriDays(dateTimeToDay(DateTime.now()));
      }
      if (value[2]) {
        DateTime now = dayToDateTime(dateTimeToDay(DateTime.now()));
        for (int i = 0; i < nutriDays.length; i++) {
          if (!dayToDateTime(nutriDays[i].day).isBefore(now)) {
            nutriDays[i] = NutriDay(
                nutriDays[i].day,
                baseNutriday.nutriScoreTheoric,
                baseNutriday.nutriScoreActual,
                baseNutriday.meals);
          } else {
            break;
          }
        }
        _update();
        saveNutridays(nutridays: nutriDays);
      }
    });
  }

  void _update(){
    progressController.animateTo(calculateKcalPercentage(), curve: Curves.decelerate, duration: const Duration(milliseconds: 500));
    progressController1.animateTo(calculateFatsPercentage(), curve: Curves.decelerate, duration: const Duration(milliseconds: 500));
    progressController2.animateTo(calculateCarbsPercentage(), curve: Curves.decelerate, duration: const Duration(milliseconds: 500));
    progressController3.animateTo(calculateProteinPercentage(), curve: Curves.decelerate, duration: const Duration(milliseconds: 500));

    setState(() {});
  }

  void _switchMeals(int from, int to) {
    if (to > from) {
      to = to - 1;
    }
    final Meal item = nutriDays[currentIndex].meals.removeAt(from);
    nutriDays[currentIndex].meals.insert(to, item);
    saveNutridays(nutridays: nutriDays);
  }

  void _addMeal() {
    nutriDays[currentIndex].meals.add(Meal(NutriScore(), [], false));
    setState(() {});
    saveNutridays(nutridays: nutriDays);
  }

  double calculateKcalPercentage() {
    NutriDay nutriday = nutriDays.isEmpty
        ? NutriDay(Day(0, 0, 0), NutriScore(), NutriScore(), [])
        : nutriDays[currentIndex];
    return nutriday.nutriScoreTheoric.kcal == 0 ? 1 : (nutriday.nutriScoreActual.kcal) / nutriday.nutriScoreTheoric.kcal;
  }
  double calculateFatsPercentage() {
    NutriDay nutriday = nutriDays.isEmpty
        ? NutriDay(Day(0, 0, 0), NutriScore(), NutriScore(), [])
        : nutriDays[currentIndex];
    return nutriday.nutriScoreTheoric.fats == 0 ? 1 : (nutriday.nutriScoreActual.fats) / nutriday.nutriScoreTheoric.fats;
  }
  double calculateCarbsPercentage() {
    NutriDay nutriday = nutriDays.isEmpty
        ? NutriDay(Day(0, 0, 0), NutriScore(), NutriScore(), [])
        : nutriDays[currentIndex];
    return nutriday.nutriScoreTheoric.carbs == 0 ? 1 : (nutriDays[currentIndex].nutriScoreActual.carbs) / nutriday.nutriScoreTheoric.carbs;
  }
  double calculateProteinPercentage() {
    NutriDay nutriday = nutriDays.isEmpty
        ? NutriDay(Day(0, 0, 0), NutriScore(), NutriScore(), [])
        : nutriDays[currentIndex];
    return nutriday.nutriScoreTheoric.protein == 0 ? 1 : nutriday.nutriScoreActual.protein / nutriday.nutriScoreTheoric.protein;
  }


  @override
  Widget build(BuildContext context) {
    NutriDay currentNutriDay = nutriDays.isEmpty
        ? NutriDay(Day(0, 0, 0), NutriScore(), NutriScore(), [])
        : nutriDays[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageMap[widget.l]?["Nutrition"] ?? "",
          style: const TextStyle(
            color: AppColors.text1,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
              onPressed: () => _startNutriSettingsPage(context),
              icon: const Icon(Icons.settings)),
          IconButton(onPressed: () => _addMeal(), icon: const Icon(Icons.add))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Constants.padding3),
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Constants.borderRadiusValue1),
                    bottomRight: Radius.circular(Constants.borderRadiusValue1)),
                color: AppColors.secondary,
              ),
              child: Padding(
                padding: const EdgeInsets.all(Constants.padding3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            children: [
                              Center(
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween<double>(
                                      begin: progressController.value,
                                      end: calculateKcalPercentage(),
                                    ),
                                    duration: const Duration(milliseconds: 500),
                                    builder: (context, value, child) {
                                      return CircularProgressIndicator(
                                        value: value,
                                        strokeWidth: 10.0,
                                        backgroundColor: AppColors.background1,
                                        color: AppColors.primary,
                                      );
                                    },
                                  ),
                                ),
                              ),
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        languageMap[widget.l]?["Calories"] ??
                                            "Calories",
                                        style: TextStyles.textStyle2,
                                      ),
                                      Text(
                                        currentNutriDay.nutriScoreActual.kcal.toString(),
                                        style: TextStyles.textStyle2,
                                      ),
                                      Text(
                                        currentNutriDay.nutriScoreTheoric.kcal.toString(),
                                        style: TextStyles.textStyle3,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                languageMap[widget.l]?["Day streak"] ?? "Day streak",
                                style: TextStyles.textStyle2,
                              ),
                              Container(
                                height: 50,
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(25)),
                                  color: AppColors.primary,
                                ),
                                child: Center(
                                  child: Text(
                                      "0", // TODO calculate streak
                                    style: TextStyles.textStyle2,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: Constants.padding3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                languageMap[widget.l]?["Fats"] ??
                                    "Fats",
                                style: TextStyles.textStyle2,
                              ),
                              Row(
                                children: [
                                  Text(
                                    currentNutriDay.nutriScoreActual.fats.toString(),
                                    style: TextStyles.textStyle2,
                                  ),
                                  Text(
                                    " / ${currentNutriDay.nutriScoreTheoric.fats.toString()}",
                                    style: TextStyles.textStyle3,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 100,
                                height: 10,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: progressController1.value,
                                    end: calculateFatsPercentage(),
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, value, child) {
                                    return LinearProgressIndicator(
                                      value: value,
                                      borderRadius: BorderRadius.circular(10),
                                      backgroundColor: AppColors.background1,
                                      color: AppColors.primary,
                                      minHeight: 5.0,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                languageMap[widget.l]?["Carbs"] ??
                                    "Carbs",
                                style: TextStyles.textStyle2,
                              ),
                              Row(
                                children: [
                                  Text(
                                    currentNutriDay.nutriScoreActual.carbs.toString(),
                                    style: TextStyles.textStyle2,
                                  ),
                                  Text(
                                    " / ${currentNutriDay.nutriScoreTheoric.carbs.toString()}",
                                    style: TextStyles.textStyle3,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 100,
                                height: 10,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: progressController2.value,
                                    end: calculateCarbsPercentage(),
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, value, child) {
                                    return LinearProgressIndicator(
                                      value: value,
                                      borderRadius: BorderRadius.circular(10),
                                      backgroundColor: AppColors.background1,
                                      color: AppColors.primary,
                                      minHeight: 5.0,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                languageMap[widget.l]?["Proteins"] ??
                                    "Proteins",
                                style: TextStyles.textStyle2,
                              ),
                              Row(
                                children: [
                                  Text(
                                    currentNutriDay.nutriScoreActual.protein.toString(),
                                    style: TextStyles.textStyle2,
                                  ),
                                  Text(
                                    " / ${currentNutriDay.nutriScoreTheoric.protein.toString()}",
                                    style: TextStyles.textStyle3,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 100,
                                height: 10,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: progressController3.value,
                                    end: calculateProteinPercentage(),
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                  builder: (context, value, child) {
                                    return LinearProgressIndicator(
                                      value: value,
                                      borderRadius: BorderRadius.circular(10),
                                      backgroundColor: AppColors.background1,
                                      color: AppColors.primary,
                                      minHeight: 5.0,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: currentNutriDay.meals.isNotEmpty
                  ? ReorderableListView.builder(
                      itemCount: currentNutriDay.meals.length,
                      itemBuilder: (context, mealIndex) {
                        final meal = currentNutriDay.meals[mealIndex];
                        return MealElement(
                          key: ValueKey(meal.hashCode),
                          nutriDays: nutriDays,
                          nutriDayIndex: currentIndex,
                          mealIndex: mealIndex,
                          update: (newNutriDays) {
                            nutriDays = newNutriDays;
                            _update();
                            saveNutridays(nutridays: nutriDays);
                          },
                          l: widget.l,
                        );
                      },
                      onReorder: (int oldIndex, int newIndex) =>
                          _switchMeals(oldIndex, newIndex),
                    )
                  : const SizedBox(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 16.0, right: 16.0, left: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton(
                    onPressed: () => _loadNutriDays(currentNutriDay.day - 1),
                    backgroundColor: AppColors.primary,
                    heroTag: 'prevExButton',
                    child: const Icon(
                        Icons.arrow_left), // Unique tag for this button
                  ),
                  Text(
                    currentNutriDay.day.toString(),
                    style: const TextStyle(
                      fontSize: Constants.fontSize2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FloatingActionButton(
                    onPressed: () => _loadNutriDays(currentNutriDay.day + 1),
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
    );
  }
}

class MealElement extends StatelessWidget {
  final String l;
  final List<NutriDay> nutriDays;
  final int nutriDayIndex;
  final int mealIndex;
  final void Function(List<NutriDay>) update;

  const MealElement({
    super.key,
    required this.l,
    required this.nutriDays,
    required this.nutriDayIndex,
    required this.mealIndex,
    required this.update,
  });

  void _removeMealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[l]?["Delete meal"] ?? ""),
          content: Text(languageMap[l]
                  ?["Are you sure you want to delete the meal?"] ??
              ""),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(languageMap[l]?["Cancel"] ?? "",
                  style: const TextStyle(color: AppColors.primary)),
            ),
            TextButton(
              onPressed: () => _removeMeal(context),
              child: Text(languageMap[l]?["Delete"] ?? "",
                  style: const TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _removeMeal(BuildContext context) {
    nutriDays[nutriDayIndex].meals.removeAt(mealIndex);
    update(nutriDays);
    Navigator.of(context).pop();
  }

  void _cheatMeal() {
    if (!nutriDays[nutriDayIndex].meals[mealIndex].cheat) {
      nutriDays[nutriDayIndex].meals[mealIndex].cheat = true;
      nutriDays[nutriDayIndex].meals[mealIndex].done = true;
      update(nutriDays);
    } else {
      nutriDays[nutriDayIndex].meals[mealIndex].cheat = false;
      nutriDays[nutriDayIndex].meals[mealIndex].done = false;
      update(nutriDays);
    }
  }

  void _startMealPage(BuildContext context, int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MealPage(
                l: l,
                initialNutriDays: nutriDays,
                nutriDayIndex: nutriDayIndex,
                mealIndex: i,
                setings: false,
              )),
    ).then((updatedNutridays) {
      if (updatedNutridays != null) {
        update(updatedNutridays as List<NutriDay>);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    nutriDays[nutriDayIndex].meals[mealIndex].updateNutriScore();
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Checkbox(
            value: nutriDays[nutriDayIndex].meals[mealIndex].done,
            onChanged: (bool? value) {
              if (value != null) {
                nutriDays[nutriDayIndex].meals[mealIndex].done = value;
                nutriDays[nutriDayIndex].updateNutriScoresActual();
                update(nutriDays);
              }
            },
            activeColor: AppColors.background2,
            checkColor: AppColors.primary,
          ),
          nutriDays[nutriDayIndex].meals[mealIndex].cheat
              ? Expanded(
                  flex: 2,
                  child: Text(
                    languageMap[l]?["Cheat meal"] ?? "",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: Constants.fontSize2,
                    ),
                  ),
                )
              : Expanded(
                  flex: 2,
                  child: Column(
                    children: nutriDays[nutriDayIndex]
                        .meals[mealIndex]
                        .portions
                        .map((portion) => Column(
                              children: [
                                Text(
                                    '${portion.aliment.name}\n${portion.grams}g',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.text1,
                                      fontSize: Constants.fontSize3,
                                    ),
                                    overflow: TextOverflow.fade),
                                nutriDays[nutriDayIndex]
                                            .meals[mealIndex]
                                            .portions
                                            .indexOf(portion) !=
                                        nutriDays[nutriDayIndex]
                                                .meals[mealIndex]
                                                .portions
                                                .length -
                                            1
                                    ? const Divider()
                                    : const SizedBox()
                              ],
                            ))
                        .toList(),
                  ),
                ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                      "${languageMap[l]?["Calories"] ?? ""}: ${nutriDays[nutriDayIndex].meals[mealIndex].nutriScore.kcal}"),
                ),
                Column(
                  children: [
                    Text(
                        "${languageMap[l]?["Proteins"] ?? ""}: ${nutriDays[nutriDayIndex].meals[mealIndex].nutriScore.protein}"),
                    Text(
                        "${languageMap[l]?["Carbs"] ?? ""}: ${nutriDays[nutriDayIndex].meals[mealIndex].nutriScore.carbs}"),
                    Text(
                        "${languageMap[l]?["Fats"] ?? ""}: ${nutriDays[nutriDayIndex].meals[mealIndex].nutriScore.fats}"),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Stack(children: [
              const CircularProgressIndicator(
                value: 1,
                strokeWidth: 6.0,
                backgroundColor: Colors.transparent,
                color: AppColors.background1,
              ),
              CircularProgressIndicator(
                value: nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .protein +
                            nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .fats +
                            nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .carbs ==
                        0
                    ? 0.66
                    : (nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .protein +
                            nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .carbs) /
                        (nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .protein +
                            nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .fats +
                            nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .carbs),
                strokeWidth: 6.0,
                backgroundColor: Colors.transparent,
                color: AppColors.secondary,
              ),
              CircularProgressIndicator(
                value: nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .protein +
                            nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .fats +
                            nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .carbs ==
                        0
                    ? 0.33
                    : (nutriDays[nutriDayIndex]
                            .meals[mealIndex]
                            .nutriScore
                            .protein) /
                        (nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .protein +
                            nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .fats +
                            nutriDays[nutriDayIndex]
                                .meals[mealIndex]
                                .nutriScore
                                .carbs),
                strokeWidth: 6.0,
                backgroundColor: Colors.transparent,
                color: AppColors.primary,
              ),
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final RelativeRect position = RelativeRect.fromRect(
                Rect.fromPoints(
                  button.localToGlobal(button.size.topRight(Offset.zero),
                      ancestor: overlay),
                  button.localToGlobal(button.size.bottomRight(Offset.zero),
                      ancestor: overlay),
                ),
                Offset.zero & overlay.size,
              );

              showMenu(
                context: context,
                position: position,
                items: [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(languageMap[l]?["Edit"] ?? ""),
                  ),
                  PopupMenuItem(
                    value: 'cheat',
                    child: Text(languageMap[l]?["Cheat meal"] ?? ""),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(languageMap[l]?["Delete"] ?? ""),
                  ),
                ],
              ).then((value) {
                if (value == 'edit') {
                  _startMealPage(context, mealIndex);
                } else if (value == 'cheat') {
                  _cheatMeal();
                } else if (value == 'delete') {
                  _removeMealDialog(context);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
