import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Muscle {
  String name;
  int muscle;

  Muscle(this.name, this.muscle);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'muscle': muscle,
    };
  }

  factory Muscle.fromJson(Map<String, dynamic> json) {
    return Muscle(json['name'], json['muscle']);
  }
}

class BaseEx {
  String name;
  String description = "";
  int maxPointReps = 0;
  int maxPointKg = 0;
  int maxPoint = 0;
  Muscle muscle = muscles[0];

  BaseEx(this.name, { this.description = ""});

  @override
  String toString() {
    return 'BaseEx{name: $name, maxPointSet: $maxPointReps, maxPointKg: $maxPointKg, maxPoint: $maxPoint}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maxPointReps': maxPointReps,
      'maxPointKg': maxPointKg,
      'maxPoint': maxPoint,
      'muscle': muscle.toJson(),
    };
  }
  factory BaseEx.fromJson(Map<String, dynamic> json) {
    BaseEx baseEx = BaseEx("")
      ..muscle = Muscle.fromJson(json['muscle'])
      ..maxPoint = json['maxPoint']
      ..maxPointKg = json['maxPointKg']
      ..maxPointReps = json['maxPointReps']
      ..name = json['name'];
    return baseEx;
  }
}

class Ex{

  String baseEx = "";
  String notes = "";
  String setAndReps = "";
  int rest = 120;
  int tut = 1111;

  Ex();

  @override
  String toString() {
    return '                    Ex{baseEx: $baseEx, notes: $notes, setAndReps: $setAndReps, rest: $rest, tut: $tut}\n';
  }

  Map<String, dynamic> toJson() {
    return {
      'baseEx': baseEx,
      'notes': notes,
      'setAndReps': setAndReps,
      'rest': rest,
      'tut': tut,
    };
  }



  factory Ex.fromJson(Map<String, dynamic> json) {
    Ex ex = Ex()
      ..baseEx = json['baseEx']
      ..notes = json['notes']
      ..setAndReps = json['setAndReps']
      ..rest = json['rest'];
    return ex;
  }
}

class Workout{

  String name = "";
  List<Ex> exs = [];

  Workout({required this.name});

  @override
  String toString() {
    return '          Workout{name: $name, exs:\n $exs\n}';
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exs': exs.map((ex) => ex.toJson()).toList(),
    };
  }
  factory Workout.fromJson(Map<String, dynamic> json) {
    Workout workout = Workout(name: "")..name = json['name'];
    if (json['exs'] != null) {
      json['exs'].forEach((v) {
        workout.exs.add(Ex.fromJson(v));
      });
    }
    return workout;
  }
}

class Plan{

  String name = "";
  List<Workout> workouts = [];

  Plan({required this.name});


  @override
  String toString() {
    return 'Plan{name: $name, workouts:\n$workouts\n}';
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'workouts': workouts.map((workout) => workout.toJson()).toList(),
    };
  }
  factory Plan.fromJson(Map<String, dynamic> json) {
    Plan plan = Plan(name:"")..name = json['name'];
    if (json['workouts'] != null) {
      json['workouts'].forEach((v) {
        plan.workouts.add(Workout.fromJson(v));
      });
    }
    return plan;
  }
}

List<Muscle> muscles = [
  Muscle("-", 0),
  Muscle("Shoulders - Anterior deltoid", 1),
  Muscle("Shoulders - Lateral deltoid", 2),
  Muscle("Shoulders - Rear deltoid", 3),

  Muscle("Chest - High", 4),
  Muscle("Chest - Medium", 5),
  Muscle("Chest - Low", 6),

  Muscle("Arms - Triceps", 7),
  Muscle("Arms - Biceps", 8),
  Muscle("Arms - Extensors", 9),
  Muscle("Arms - Flexors", 10),

  Muscle("Back - General", 11),
  Muscle("Back - Trapezius", 12),
  Muscle("Back - Rhomboids", 13),
  Muscle("Back - Latissimus Dorsi", 14),
  Muscle("Back - Teres Major", 15),
  Muscle("Back - Lumbar", 16),

  Muscle("Legs - General", 17),
  Muscle("Legs - Quadriceps", 18),
  Muscle("Legs - Hamstrings", 19),
  Muscle("Legs - Gluteus", 20),
  Muscle("Legs - Calves", 21),

  Muscle("Abdominals", 22)
];

Future<List<BaseEx>> loadBaseExs() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/baseEx.json');
  if (!file.existsSync()) {
    return [];
  }
  String contents = await file.readAsString();
  List<dynamic> jsonList = json.decode(contents);

  //print("Loaded:\n$jsonList");

  return jsonList.map((json) => BaseEx.fromJson(json)).toList();
}
Future<void> saveBaseExs({List<BaseEx> baseExs = const []}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/baseEx.json');
  List<Map<String, dynamic>> jsonList = baseExs.map((baseEx) => baseEx.toJson()).toList();
  await file.writeAsString(json.encode(jsonList));
  //print("Saved:\n$baseExs");
}

Future<List<Plan>> loadPlans() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/plans.json');
  if (!file.existsSync()) {
    return [];
  }
  String contents = await file.readAsString();
  List<dynamic> jsonList = json.decode(contents);

  //print("Loaded:\n$jsonList");

  return jsonList.map((json) => Plan.fromJson(json)).toList();
}
Future<void> savePlans({required List<Plan> plans}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/plans.json');
  List<Map<String, dynamic>> jsonList = plans.map((plan) => plan.toJson()).toList();
  await file.writeAsString(json.encode(jsonList));
  //print("Saved:\n$plans");
}

Future<List<int>> loadNextWorkout() async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/nextWorkout.json');
  if (!file.existsSync()) {
    return [-1, -1];
  }
  String contents = await file.readAsString();
  List<dynamic> jsonList = json.decode(contents);
  print("Loaded Index:" + jsonList.toString());
  return jsonList.cast<int>();
}
Future<void> saveNextWorkout({required List<int> indices}) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/nextWorkout.json');
  await file.writeAsString(json.encode(indices));
  print("Saved Index:" + indices.toString());
}
