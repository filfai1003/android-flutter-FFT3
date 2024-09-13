import 'package:fft/nutri_data.dart';
import 'package:flutter/material.dart';

import 'general_data.dart';
import 'general_language.dart';
import 'general_style.dart';
import 'nutri_meal.dart';

class NutriSettingsPage extends StatefulWidget {
  final String l;

  const NutriSettingsPage({super.key, required this.l});

  @override
  State<NutriSettingsPage> createState() => _NutriSettingsPageState();
}

class _NutriSettingsPageState extends State<NutriSettingsPage> with TickerProviderStateMixin {
  late NutriDay initialNutriDay;
  late NutriDay nutriDay = NutriDay(Day(0,0,0), NutriScore(), NutriScore(), []);
  late TextEditingController proteinController = TextEditingController();
  late TextEditingController fatsController = TextEditingController();
  late TextEditingController carbsController = TextEditingController();
  late TextEditingController saltController = TextEditingController();
  late TextEditingController kcalController = TextEditingController();
  late AnimationController progressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late AnimationController progressController1 = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 500),
  );

  bool reset = false;

  @override
  void initState() {
    _init();
    super.initState();
  }
  @override
  void dispose() {
    proteinController.dispose();
    fatsController.dispose();
    carbsController.dispose();
    saltController.dispose();
    kcalController.dispose();

    progressController.dispose();
    progressController1.dispose();
    super.dispose();

  }
  void _goBackWithUpdatedNutriDays() {
    Navigator.pop(context, [nutriDay, reset, nutriDay!=initialNutriDay]);
  }
  Future<void> _init() async {

    initialNutriDay = await loadNutriDay(Day(0, 0, 0));
    nutriDay = await loadNutriDay(Day(0, 0, 0));

    proteinController = TextEditingController(text: nutriDay.nutriScoreTheoric.protein.toString());
    fatsController = TextEditingController(text: nutriDay.nutriScoreTheoric.fats.toString());
    carbsController = TextEditingController(text: nutriDay.nutriScoreTheoric.carbs.toString());
    saltController = TextEditingController(text: nutriDay.nutriScoreTheoric.salt.toString());
    kcalController = TextEditingController(text: nutriDay.nutriScoreTheoric.kcal.toString());

    setState(() {});
  }

  void _addMeal() {
    nutriDay.meals.add(Meal(NutriScore(), [], false));
    nutriDay.updateNutriScoresTheoric();
    _update();
    saveNutriDay(nutriDay);
  }
  void _switchMeals(int from, int to) {
    if (to > from) {
      to = to - 1;
    }
    final Meal item = nutriDay.meals.removeAt(from);
    nutriDay.meals.insert(to, item);

    saveNutriDay(nutriDay);
  }
  void _deleteAllDataDialog() {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageMap[widget.l]?["Delete all data"] ?? ""),
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
                  saveNutridays(nutridays: []);
                  reset = true;
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
  double calculateProteinPercentage() {
    final total = nutriDay.nutriScoreTheoric.protein + nutriDay.nutriScoreTheoric.carbs + nutriDay.nutriScoreTheoric.fats;
    return total == 0 ? 0.33 : nutriDay.nutriScoreTheoric.protein / total;
  }
  double calculateCarbsPercentage() {
    final total = nutriDay.nutriScoreTheoric.protein + nutriDay.nutriScoreTheoric.carbs + nutriDay.nutriScoreTheoric.fats;
    return total == 0 ? 0.66 : (nutriDay.nutriScoreTheoric.protein + nutriDay.nutriScoreTheoric.carbs) / total;
  }

  void _saveMacro(int i, String newData) {
    if (newData.isEmpty) {
      newData= "0";
    }
    if (i == 0) {
      nutriDay.nutriScoreTheoric.protein = int.parse(newData);
    } else if (i == 1) {
      nutriDay.nutriScoreTheoric.fats = int.parse(newData);
    } else if (i == 2) {
      nutriDay.nutriScoreTheoric.kcal = int.parse(newData);
    } else if (i == 3) {
      nutriDay.nutriScoreTheoric.carbs = int.parse(newData);
    } else if (i == 4) {
      nutriDay.nutriScoreTheoric.salt = int.parse(newData);
    }

    _update();
    saveNutriDay(nutriDay);
  }
  void _saveMeals(List<Meal> newMeals) {
    nutriDay.meals = newMeals;
    nutriDay.updateNutriScoresTheoric();

    _update();
    saveNutriDay(nutriDay);
  }
  void _update(){
    progressController.animateTo(calculateProteinPercentage(), curve: Curves.decelerate, duration: const Duration(milliseconds: 500));
    progressController1.animateTo(calculateCarbsPercentage(), curve: Curves.decelerate, duration: const Duration(milliseconds: 500));

    proteinController.text = nutriDay.nutriScoreTheoric.protein.toString();
    fatsController.text = nutriDay.nutriScoreTheoric.fats.toString();
    carbsController.text = nutriDay.nutriScoreTheoric.carbs.toString();
    saltController.text = nutriDay.nutriScoreTheoric.salt.toString();
    kcalController.text = nutriDay.nutriScoreTheoric.kcal.toString();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBackWithUpdatedNutriDays();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            languageMap[widget.l]?["Set your diet"] ?? "",
            style: const TextStyle(
              color: AppColors.text1,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(onPressed: () => _deleteAllDataDialog(), icon: const Icon(Icons.delete)),
            IconButton(onPressed: () => _addMeal(), icon: const Icon(Icons.add))
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(Constants.borderRadiusValue1),
                  color: AppColors.background2,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      languageMap[widget.l]?["Proteins"] ?? "",
                                      style: const TextStyle(
                                        fontSize: Constants.fontSize2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      width: 100,
                                      child: TextFormField(
                                        controller: proteinController,
                                        keyboardType: TextInputType.number,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => _saveMacro(0, value),
                                        enabled: nutriDay.meals.isEmpty,
                                        style: const TextStyle(
                                          fontSize: Constants.fontSize2,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text1,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          border: nutriDay.meals.isEmpty
                                              ? const OutlineInputBorder()
                                              : InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      languageMap[widget.l]?["Fats"] ?? "",
                                      style: const TextStyle(
                                        fontSize: Constants.fontSize2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      width: 100,
                                      child: TextFormField(
                                        controller: fatsController,
                                        keyboardType: TextInputType.number,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => _saveMacro(1, value),
                                        enabled: nutriDay.meals.isEmpty,
                                        style: const TextStyle(
                                          fontSize: Constants.fontSize2,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text1,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          border: nutriDay.meals.isEmpty
                                              ? const OutlineInputBorder()
                                              : InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  languageMap[widget.l]?["Calories"] ?? "",
                                  style: const TextStyle(
                                    fontSize: Constants.fontSize2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  width: 100,
                                  child: TextFormField(
                                    controller: kcalController,
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    onChanged: (value) => _saveMacro(2, value),
                                    enabled: nutriDay.meals.isEmpty,
                                    style: const TextStyle(
                                      fontSize: Constants.fontSize2,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.text1,
                                    ),
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(vertical: 10.0),
                                      border: nutriDay.meals.isEmpty
                                          ? const OutlineInputBorder()
                                          : InputBorder.none,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Stack(children: [
                                    const Center(
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: CircularProgressIndicator(
                                          value: 1,
                                          strokeWidth: 10.0,
                                          backgroundColor: Colors.transparent,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                              AppColors.background1),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                            begin: progressController.value,
                                            end: calculateCarbsPercentage(),
                                          ),
                                          duration: const Duration(milliseconds: 500),
                                          builder: (context, value, child) {
                                            return CircularProgressIndicator(
                                              value: value,
                                              strokeWidth: 10.0,
                                              backgroundColor: Colors.transparent,
                                              color: AppColors.secondary,
                                            );
                                          },
                                        )
                                      ),
                                    ),
                                    Center(
                                      child: SizedBox(
                                        width: 100,
                                        height: 100,
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                            begin: progressController1.value,
                                            end: calculateProteinPercentage(),
                                          ),
                                          duration: const Duration(milliseconds: 500),
                                          builder: (context, value, child) {
                                            return CircularProgressIndicator(
                                              value: value,
                                              strokeWidth: 10.0,
                                              backgroundColor: Colors.transparent,
                                              color: AppColors.primary,
                                            );
                                          },
                                        )
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      languageMap[widget.l]?["Carbs"] ?? "",
                                      style: const TextStyle(
                                        fontSize: Constants.fontSize2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      width: 100,
                                      child: TextFormField(
                                        controller: carbsController,
                                        keyboardType: TextInputType.number,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => _saveMacro(3, value),
                                        enabled: nutriDay.meals.isEmpty,
                                        style: const TextStyle(
                                          fontSize: Constants.fontSize2,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text1,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          border: nutriDay.meals.isEmpty
                                              ? const OutlineInputBorder()
                                              : InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      languageMap[widget.l]?["Salt"] ?? "",
                                      style: const TextStyle(
                                        fontSize: Constants.fontSize2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      width: 100,
                                      child: TextFormField(
                                        controller: saltController,
                                        keyboardType: TextInputType.number,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => _saveMacro(4, value),
                                        enabled: nutriDay.meals.isEmpty,
                                        style: const TextStyle(
                                          fontSize: Constants.fontSize2,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.text1,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          border: nutriDay.meals.isEmpty
                                              ? const OutlineInputBorder()
                                              : InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
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
                child: SizedBox(
                  width: double.infinity,
                  height: 500,
                  child: nutriDay.meals.isNotEmpty
                      ? ReorderableListView.builder(
                          itemCount: nutriDay.meals.length,
                          itemBuilder: (context, mealIndex) {
                            final meal = nutriDay.meals[mealIndex];
                            return MealOptionElement(
                              key: ValueKey(meal.hashCode),
                              nutriDay: nutriDay,
                              mealIndex: mealIndex,
                              update: (meals) => _saveMeals(meals),
                              l: widget.l,
                            );
                          },
                          onReorder: (int oldIndex, int newIndex) =>
                              _switchMeals(oldIndex, newIndex),
                        )
                      : const SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealOptionElement extends StatelessWidget {
  final String l;
  NutriDay nutriDay;
  final int mealIndex;
  final void Function(List<Meal>) update;

  MealOptionElement(
      {super.key,
      required this.l,
      required this.nutriDay,
      required this.mealIndex,
      required this.update});

  void _removeMeal(BuildContext context) {
    nutriDay.meals.removeAt(mealIndex);
    update(nutriDay.meals);
  }

  void _startMealPage(BuildContext context, int i){
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MealPage(
            l: l,
            initialNutriDays: [nutriDay],
            nutriDayIndex: 0,
            mealIndex: i,
            setings: false,
          )),
    ).then((updatedNutridays) {
        update((updatedNutridays[0] as NutriDay).meals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                  flex: 2,
                  child: Column(
                    children: nutriDay.meals[mealIndex].portions
                        .map((portion) => Column(
                              children: [
                                Text('${portion.aliment.name}\n${portion.grams}g',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.text1,
                                      fontSize: Constants.fontSize3,
                                    ),
                                    overflow: TextOverflow.fade),
                                nutriDay.meals[mealIndex].portions
                                            .indexOf(portion) !=
                                        nutriDay.meals[mealIndex].portions
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
                            "${languageMap[l]?["Calories"] ?? ""}: ${nutriDay.meals[mealIndex].nutriScore.kcal}"),
                      ),
                      Column(
                        children: [
                          Text(
                              "${languageMap[l]?["Proteins"] ?? ""}: ${nutriDay.meals[mealIndex].nutriScore.protein}"),
                          Text(
                              "${languageMap[l]?["Carbs"] ?? ""}: ${nutriDay.meals[mealIndex].nutriScore.carbs}"),
                          Text(
                              "${languageMap[l]?["Fats"] ?? ""}: ${nutriDay.meals[mealIndex].nutriScore.fats}"),
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
                      value: nutriDay.meals[mealIndex].nutriScore.protein +
                                  nutriDay.meals[mealIndex].nutriScore.fats +
                                  nutriDay.meals[mealIndex].nutriScore.carbs ==
                              0
                          ? 0.66
                          : (nutriDay.meals[mealIndex].nutriScore.protein +
                                  nutriDay.meals[mealIndex].nutriScore.carbs) /
                              (nutriDay.meals[mealIndex].nutriScore.protein +
                                  nutriDay.meals[mealIndex].nutriScore.fats +
                                  nutriDay.meals[mealIndex].nutriScore.carbs),
                      strokeWidth: 6.0,
                      backgroundColor: Colors.transparent,
                      color: AppColors.secondary,
                    ),
                    CircularProgressIndicator(
                      value: nutriDay.meals[mealIndex].nutriScore.protein +
                                  nutriDay.meals[mealIndex].nutriScore.fats +
                                  nutriDay.meals[mealIndex].nutriScore.carbs ==
                              0
                          ? 0.33
                          : (nutriDay.meals[mealIndex].nutriScore.protein) /
                              (nutriDay.meals[mealIndex].nutriScore.protein +
                                  nutriDay.meals[mealIndex].nutriScore.fats +
                                  nutriDay.meals[mealIndex].nutriScore.carbs),
                      strokeWidth: 6.0,
                      backgroundColor: Colors.transparent,
                      color: AppColors.primary,
                    ),
                  ]),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
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
                        value: 'delete',
                        child: Text(languageMap[l]?["Delete"] ?? ""),
                      ),
                    ],
                  ).then((value) {
                    if (value == 'edit') {
                      _startMealPage(context, mealIndex);
                    } else if (value == 'delete') {
                      _removeMeal(context);
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
