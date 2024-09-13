import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'general_data.dart';

class NutriScore {
  int kcal;
  int protein;
  int carbs;
  int fats;
  int salt;

  NutriScore(
      {this.kcal = 0,
      this.protein = 0,
      this.carbs = 0,
      this.fats = 0,
      this.salt = 0});

  NutriScore operator +(NutriScore other) {
    return NutriScore(
      kcal: this.kcal + other.kcal,
      protein: this.protein + other.protein,
      carbs: this.carbs + other.carbs,
      fats: this.fats + other.fats,
      salt: this.salt + other.salt,
    );
  }

  NutriScore operator *(double factor) {
    return NutriScore(
      kcal: (this.kcal * factor).round(),
      protein: (this.protein * factor).round(),
      carbs: (this.carbs * factor).round(),
      fats: (this.fats * factor).round(),
      salt: (this.salt * factor).round(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kcal': kcal,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'salt': salt,
    };
  }

  factory NutriScore.fromJson(Map<String, dynamic> json) {
    return NutriScore(
      kcal: json['kcal'] ?? 0,
      protein: json['protein'] ?? 0,
      carbs: json['carbs'] ?? 0,
      fats: json['fats'] ?? 0,
      salt: json['salt'] ?? 0,
    );
  }

  String toString() {
    return 'NutriScore(kcal: $kcal, protein: $protein, carbs: $carbs, fats: $fats, salt: $salt)';
  }
}

class Aliment {
  String name;
  NutriScore nutriScore;
  int type;

  Aliment(this.name, this.nutriScore, {this.type = 3});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'nutriScore': nutriScore.toJson(),
    };
  }

  factory Aliment.fromJson(Map<String, dynamic> json) {
    return Aliment(
      json['name'],
      NutriScore.fromJson(json['nutriScore']),
      type: json['type']
    );
  }

  String toString() {
    return 'Aliment(name: $name, nutriScore: $nutriScore)';
  }
}

class Portion {
  Aliment aliment;
  int grams;

  Portion(this.aliment, this.grams);

  Map<String, dynamic> toJson() {
    return {
      'aliment': aliment.toJson(),
      'grams': grams,
    };
  }

  factory Portion.fromJson(Map<String, dynamic> json) {
    return Portion(
      Aliment.fromJson(json['aliment']),
      json['grams'],
    );
  }

  String toString() {
    return 'Portion(aliment: $aliment, grams: $grams)';
  }
}

class Meal {
  NutriScore nutriScore;
  bool done;
  bool cheat;
  List<Portion> portions;

  Meal(this.nutriScore, this.portions, this.done, {this.cheat = false});

  void updateNutriScore() {
    NutriScore updatedScore = NutriScore();
    for (Portion portion in portions) {
      updatedScore += portion.aliment.nutriScore * (portion.grams / 100.0);
    }
    this.nutriScore = updatedScore;
  }

  Map<String, dynamic> toJson() {
    return {
      'nutriScore': nutriScore.toJson(),
      'done': done,
      'cheat': cheat, // Include the cheat flag in the JSON output
      'portions': portions.map((portion) => portion.toJson()).toList(),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    Meal meal = Meal(
      NutriScore.fromJson(json['nutriScore']),
      (json['portions'] as List<dynamic>)
          .map((portionJson) => Portion.fromJson(portionJson))
          .toList(),
      json['done'],
      cheat: json['cheat'] as bool ?? false,
    );
    meal.updateNutriScore();
    return meal;
  }

  String toString() {
    return 'Meal(nutriScore: $nutriScore, done: $done, cheat: $cheat, portions: ${portions.map((portion) => portion.toString()).join(', ')})';
  }
}

class NutriDay {
  Day day;
  NutriScore nutriScoreTheoric;
  NutriScore nutriScoreActual;
  List<Meal> meals;

  NutriDay(this.day, this.nutriScoreTheoric, this.nutriScoreActual, this.meals);

  void updateNutriScoresActual() {
    NutriScore total = NutriScore();
    for (Meal meal in meals) {
      if (meal.done) {
        total += meal.nutriScore;
      }
    }
    this.nutriScoreActual = total;
  }

  void updateNutriScoresTheoric() {
    if (meals.length == 0){
      return;
    }
    NutriScore total = NutriScore();
    for (Meal meal in meals) {
      total += meal.nutriScore;
    }
    this.nutriScoreTheoric = total;
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day.toJson(),
      'nutriScoreTheoric': nutriScoreTheoric.toJson(),
      'nutriScoreActual': nutriScoreActual.toJson(),
      'meals': meals.map((meal) => meal.toJson()).toList(),
    };
  }

  factory NutriDay.fromJson(Map<String, dynamic> json) {
    NutriDay nutriday = NutriDay(
      Day.fromJson(json['day']),
      NutriScore.fromJson(json['nutriScoreTheoric']),
      NutriScore.fromJson(json['nutriScoreActual']),
      (json['meals'] as List<dynamic>)
          .map((mealJson) => Meal.fromJson(mealJson))
          .toList(),
    );
    nutriday.updateNutriScoresActual(); // Ensure nutriScores are correct upon loading
    return nutriday;
  }

  String toString() {
    return 'NutriDay(day: $day), theoricNutriScore: $nutriScoreTheoric, actualNutriScore: $nutriScoreActual, meals: ${meals.map((meal) => meal.toString()).join(', ')})\n';
  }
}

Map<int, String> types = {
  0:"Proteins",
  1:"Carbs",
  2:"Fats",
  3:"Other",
};

Future<List<NutriDay>> loadNutridays() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/nutridays.json');
  if (!file.existsSync()) {
    return [];
  }
  String contents = await file.readAsString();
  List<dynamic> jsonList = json.decode(contents);

  return jsonList.map((json) => NutriDay.fromJson(json)).toList();
}

Future<void> saveNutridays({required List<NutriDay> nutridays}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/nutridays.json');
  List<Map<String, dynamic>> jsonList =
      nutridays.map((nutriday) => nutriday.toJson()).toList();
  await file.writeAsString(json.encode(jsonList));
}

Future<NutriDay> loadNutriDay(Day day) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/nutriday.json');
  if (!file.existsSync()) {
    NutriDay ret = NutriDay(
        day, NutriScore(protein: 100, fats: 50, carbs: 10), NutriScore(), [
      Meal(
          NutriScore(protein: 100, fats: 50, carbs: 10),
          [
            Portion(
                Aliment("pollo", NutriScore(protein: 100, fats: 50, carbs: 10)),
                100)
          ],
          false)
    ]);
    ret.updateNutriScoresActual();
    print(ret);
    return ret;
  }
  String contents = await file.readAsString();
  Map<String, dynamic> jsonMap = json.decode(contents);
  NutriDay ret = NutriDay.fromJson(jsonMap)..day = day;
  ret.updateNutriScoresActual();
  ret.updateNutriScoresTheoric();
  return ret;
}

Future<void> saveNutriDay(NutriDay nutriday) async {
  nutriday.updateNutriScoresTheoric();
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/nutriday.json');
  Map<String, dynamic> jsonMap = nutriday.toJson();
  await file.writeAsString(json.encode(jsonMap));
}

Future<List<Aliment>> loadAliments() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/aliments.json');
  if (!file.existsSync()) {
    return [];
  }
  String contents = await file.readAsString();
  List<dynamic> jsonList = json.decode(contents);

  return jsonList.map((json) => Aliment.fromJson(json)).toList();
}
Future<void> saveAliments({List<Aliment> aliments = const []}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/aliments.json');
  List<Map<String, dynamic>> jsonList = aliments.map((aliments) => aliments.toJson()).toList();
  await file.writeAsString(json.encode(jsonList));
}