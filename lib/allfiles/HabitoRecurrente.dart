import 'Tarea.dart';

class HabitoRecurrente extends Tarea {
  int racha;

  HabitoRecurrente({
    required String titulo,
    String descripcion = '',
    required DateTime fechaLimite,
    int prioridad = 2,
    String categoria = 'General',
    this.racha = 0,
  }) : super(
         titulo: titulo,
         descripcion: descripcion,
         fechaLimite: fechaLimite,
         prioridad: prioridad,
         categoria: categoria,
       );

  @override
  void completar() {
    super.completar();
    racha++;

    print('Racha actual: $racha');
  }
}

/*void main() {
  Tarea t1 = Tarea(
    titulo: 'Entregar informe de clase',
    descripcion: 'Entregar el informe final',
    fechaLimite: DateTime(2026, 8, 20),
    prioridad: 1,
    categoria: 'Estudio',
  );

  Tarea t2 = Tarea(
    titulo: 'Realizar guía de laboratorio #1',
    fechaLimite: DateTime(2026, 8, 22),
    prioridad: 2,
    categoria: 'Estudio',
  );

  HabitoRecurrente h1 = HabitoRecurrente(
    titulo: 'Estudiar Dart',
    descripcion: 'Repasar Dart durante 30 minutos',
    fechaLimite: DateTime(2026, 8, 25),
    prioridad: 3,
    categoria: 'Estudio',
  );

  HabitoRecurrente h2 = HabitoRecurrente(
    titulo: 'Hacer ejercicio',
    descripcion: 'Realizar 20 minutos de ejercicio',
    fechaLimite: DateTime(2026, 8, 30),
    prioridad: 2,
    categoria: 'Personal',
  );

  // Lista mixta de Tarea y HabitoRecurrente
  List<Tarea> tareas = [t1, t2, h1, h2];

  // Recorremos la lista
  for (Tarea tarea in tareas) {
    print('-----------------------------');
    print('Tarea: ${tarea.titulo}');
    print('Categoría: ${tarea.categoria}');
    print('Prioridad: ${tarea.prioridad}');

    tarea.completar();
  }
}
*/
