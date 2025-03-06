import '../models/counter_model.dart';

class CounterController {
  final CounterModel _model = CounterModel();
  
  int get count => _model.value;
  
  void incrementCounter() {
    _model.increment();
  }
} 