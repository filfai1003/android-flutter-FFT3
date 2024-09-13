import 'package:fft/general_language.dart';
import 'package:fft/nutri_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'general_style.dart';
import 'nutri_alimentSeletc.dart';

class MealPage extends StatefulWidget {
  final String l;
  final List<NutriDay> initialNutriDays;
  final int nutriDayIndex;
  final int mealIndex;
  final bool setings;

  const MealPage(
      {super.key,
      required this.l,
      required this.initialNutriDays,
      required this.setings,
      required this.nutriDayIndex,
      required this.mealIndex});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  List<NutriDay> nutriDays = [];

  @override
  void initState() {
    _init();
    super.initState();
  }
  void _goBackWithUpdatedNutriDays() {
    Navigator.pop(context, nutriDays);
  }
  Future<void> _init() async {
    nutriDays = widget.initialNutriDays;
    setState(() {});
  }

  void _update() {
    setState(() {});
  }
  void _save(){
    if (widget.setings) {
      saveNutriDay(nutriDays[0]);
    } else {
      saveNutridays(nutridays: nutriDays);
    }
  }
  void _savePortions(List<Portion> newPortions){
    nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].portions = newPortions;
    nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].updateNutriScore();
    _update();
    _save();
  }

  void _addPortion(){
    nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].portions.add(Portion(Aliment("", NutriScore()), 100));
    nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].updateNutriScore();
    _update();
    _save();
  }
  void _switchPortions(int from, int to){
    if (to > from) {
      to -= 1;
    }
    final Portion item = nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].portions.removeAt(from);
    nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].portions.insert(to, item);
    _save();
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
            languageMap[widget.l]?["Meal"] ?? "",
            style: const TextStyle(
              color: AppColors.text1,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(onPressed: () => _addPortion(), icon: const Icon(Icons.add))
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(Constants.borderRadiusValue1),
                    color: AppColors.background2,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 16.0, right: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${languageMap[widget.l]?["Proteins"] ?? ''}: ${nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].nutriScore.protein.toString()}",
                                  style: const TextStyle(
                                    fontSize: Constants.fontSize2,
                                  ),
                                ),
                                Text(
                                  "${languageMap[widget.l]?["Carbs"] ?? ''}: ${nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].nutriScore.carbs.toString()}",
                                  style: const TextStyle(
                                    fontSize: Constants.fontSize2,
                                  ),
                                ),
                                Text(
                                  "${languageMap[widget.l]?["Fats"] ?? ''}: ${nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].nutriScore.fats.toString()}",
                                  style: const TextStyle(
                                    fontSize: Constants.fontSize2,
                                  ),
                                ),
                                Text(
                                  "${languageMap[widget.l]?["Salt"] ?? ''}: ${nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].nutriScore.salt.toString()}",
                                  style: const TextStyle(
                                    fontSize: Constants.fontSize2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Stack(children: [
                              const CircularProgressIndicator(
                                value: 1,
                                strokeWidth: 6.0,
                                backgroundColor: Colors.transparent,
                                color: AppColors.background1,
                              ),
                              CircularProgressIndicator(
                                value: nutriDays[widget.nutriDayIndex]
                                    .meals[widget.mealIndex]
                                    .nutriScore
                                    .protein +
                                    nutriDays[widget.nutriDayIndex]
                                        .meals[widget.mealIndex]
                                        .nutriScore
                                        .fats +
                                    nutriDays[widget.nutriDayIndex]
                                        .meals[widget.mealIndex]
                                        .nutriScore
                                        .carbs ==
                                    0
                                    ? 0.66
                                    : (nutriDays[widget.nutriDayIndex]
                                    .meals[widget.mealIndex]
                                    .nutriScore
                                    .protein +
                                    nutriDays[widget.nutriDayIndex]
                                        .meals[widget.mealIndex]
                                        .nutriScore
                                        .carbs) /
                                    (nutriDays[widget.nutriDayIndex]
                                        .meals[widget.mealIndex]
                                        .nutriScore
                                        .protein +
                                        nutriDays[widget.nutriDayIndex]
                                            .meals[widget.mealIndex]
                                            .nutriScore
                                            .fats +
                                        nutriDays[widget.nutriDayIndex]
                                            .meals[widget.mealIndex]
                                            .nutriScore
                                            .carbs),
                                strokeWidth: 6.0,
                                backgroundColor: Colors.transparent,
                                color: AppColors.secondary,
                              ),
                              CircularProgressIndicator(
                                value: nutriDays[widget.nutriDayIndex]
                                    .meals[widget.mealIndex]
                                    .nutriScore
                                    .protein +
                                    nutriDays[widget.nutriDayIndex]
                                        .meals[widget.mealIndex]
                                        .nutriScore
                                        .fats +
                                    nutriDays[widget.nutriDayIndex]
                                        .meals[widget.mealIndex]
                                        .nutriScore
                                        .carbs ==
                                    0
                                    ? 0.33
                                    : (nutriDays[widget.nutriDayIndex]
                                    .meals[widget.mealIndex]
                                    .nutriScore
                                    .protein) /
                                    (nutriDays[widget.nutriDayIndex]
                                        .meals[widget.mealIndex]
                                        .nutriScore
                                        .protein +
                                        nutriDays[widget.nutriDayIndex]
                                            .meals[widget.mealIndex]
                                            .nutriScore
                                            .fats +
                                        nutriDays[widget.nutriDayIndex]
                                            .meals[widget.mealIndex]
                                            .nutriScore
                                            .carbs),
                                strokeWidth: 6.0,
                                backgroundColor: Colors.transparent,
                                color: AppColors.primary,
                              ),
                            ]),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Text(
                              "${languageMap[widget.l]?["Calories"] ?? ''}\n${nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].nutriScore.kcal.toString()}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: Constants.fontSize2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
            Expanded(
              child: Padding(
                  padding:
                  const EdgeInsets.only(bottom: 16.0, right: 16.0, left: 16.0),
                  child:  SizedBox(
                            width: double.infinity,
                            height: 500,
                            child: nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].portions.isNotEmpty
                                ? ReorderableListView.builder(
                              itemCount: nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].portions.length,
                              itemBuilder: (context, portionIndex) {
                                final meal = nutriDays[widget.nutriDayIndex].meals[widget.mealIndex].portions[portionIndex];
                                return PortionElement(
                                  key: ValueKey(meal.hashCode),
                                  nutriDays: nutriDays,
                                  nutriDayIndex: widget.nutriDayIndex,
                                  mealIndex: widget.mealIndex,
                                  portionIndex: portionIndex,
                                  update: (newPortions) => _savePortions(newPortions),
                                  l: widget.l,
                                );
                              },
                              onReorder: (int oldIndex, int newIndex) =>
                                  _switchPortions(oldIndex, newIndex),
                            )
                                : SizedBox(),
                          ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}

class PortionElement extends StatelessWidget {
  final String l;
  final List<NutriDay> nutriDays;
  final int nutriDayIndex;
  final int mealIndex;
  final int portionIndex;
  final void Function(List<Portion>) update;
  const PortionElement({super.key, required this.l, required this.nutriDays, required this.nutriDayIndex, required this.mealIndex, required this.portionIndex, required this.update});

  void _savePortionGrams(String value){
    nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].grams = int.parse(value);
    nutriDays[nutriDayIndex].meals[mealIndex].updateNutriScore();
    update(nutriDays[nutriDayIndex].meals[mealIndex].portions);
  }
  void _removePortion(){
    nutriDays[nutriDayIndex].meals[mealIndex].portions.removeAt(portionIndex);
    update(nutriDays[nutriDayIndex].meals[mealIndex].portions);
  }
  void _startAlimentSelectionPage(BuildContext context)  {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AlimentSelectionPage(
              nutridays: nutriDays,
              nutriDayIndex: nutriDayIndex,
              mealIndex: mealIndex,
              portionIndex: portionIndex,
              l: l,
              settings: false
          )),
    ).then((updatedNutriDays) {
      if (updatedNutriDays != null) {
        update(updatedNutriDays[nutriDayIndex].meals[mealIndex].portions);
      }
    });
  }

  List<double> getTotal(){
    NutriScore nutriScore = nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].aliment.nutriScore;
    List<double> ret = [0.66,0.33];
    double tot = (nutriScore.protein + nutriScore.carbs + nutriScore.fats).toDouble();
    if (tot != 0){
      ret[0] = (nutriScore.protein + nutriScore.carbs).toDouble()/tot;
      ret[1] = (nutriScore.protein).toDouble()/tot;
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    List<double> progress = getTotal();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 3,
                  child: TextButton(
                    onPressed: () => _startAlimentSelectionPage(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: AppColors.secondary,
                    ),
                    child: Text(
                      nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].aliment.name.isEmpty ? (languageMap[l]?["Select aliment"] ?? "") : nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].aliment.name,
                      style: const TextStyle(color: Colors.black, fontSize: 17),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    initialValue: nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].grams.toString(),
                    decoration: InputDecoration(labelText: languageMap[l]?["Grams"] ?? ""),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _savePortionGrams(value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _removePortion,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "${languageMap[l]?["Proteins Letter"] ?? ''}:${(nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].aliment.nutriScore.protein*nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].grams/100).round().toString()}",
                  style: const TextStyle(
                    fontSize: Constants.fontSize3,
                  ),
                ),
                Text(
                  "${languageMap[l]?["Carbs Letter"] ?? ''}:${(nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].aliment.nutriScore.carbs*nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].grams/100).round().toString()}",
                  style: const TextStyle(
                    fontSize: Constants.fontSize3,
                  ),
                ),
                Text(
                  "${languageMap[l]?["Fats Letter"] ?? ''}:${(nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].aliment.nutriScore.fats*nutriDays[nutriDayIndex].meals[mealIndex].portions[portionIndex].grams/100).round().toString()}",
                  style: const TextStyle(
                    fontSize: Constants.fontSize3,
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                LinearProgressIndicator(
                  value: 1,
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.transparent,
                  color: AppColors.background1,
                  minHeight: 5.0,
                ),
                LinearProgressIndicator(
                  value: progress[0],
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.transparent,
                  color: AppColors.secondary,
                  minHeight: 5.0,
                ),
                LinearProgressIndicator(
                  value: progress[1],
                  borderRadius: BorderRadius.circular(10),
                  backgroundColor: Colors.transparent,
                  color: AppColors.primary,
                  minHeight: 5.0,
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}
