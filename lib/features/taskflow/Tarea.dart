class Tarea {
  String titulo;
  String descripcion;
  DateTime fechaLimite;
  bool completada = false;

  int _prioridad; // privado: 1 = baja, 2 = media, 3 = alta

  // Agregué categoria para poder organizar las tareas de TaskFlow
  // según su tipo, por ejemplo: General, Estudio, Trabajo o Personal.
  // Es privada para controlar que no se asigne una categoría vacía.
  /*
    Decidí que el atributo categoria fuera privado porque quiero controlar los valores que se le asignan. 
    Mediante un getter puedo consultar la categoría y mediante un setter puedo validar que no se asigne una categoría vacía. 
    Esto permite aplicar encapsulamiento y proteger mejor los datos de la clase.
  */
  String _categoria;

  Tarea({
    required this.titulo,
    this.descripcion = '',
    required this.fechaLimite,
    int prioridad = 2,
    String categoria = 'General',
  }) : _prioridad = prioridad,
       _categoria = categoria;

  // Getter de prioridad
  int get prioridad => _prioridad;

  // Setter de prioridad
  set prioridad(int valor) {
    if (valor >= 1 && valor <= 3) {
      _prioridad = valor;
    } else {
      print('La prioridad debe estar entre 1 (baja) y 3 (alta).');
    }
  }

  // Getter de categoria
  String get categoria => _categoria;

  // Setter de categoria
  set categoria(String valor) {
    if (valor.isNotEmpty) {
      _categoria = valor;
    } else {
      print('La categoría no puede estar vacía.');
    }
  }

  void completar() {
    completada = true;
    print('Tarea "$titulo" marcada como completada.');
  }

  // Método adicional relacionado con el nuevo atributo.
  void cambiarCategoria(String nuevaCategoria) {
    categoria = nuevaCategoria;

    print('La tarea "$titulo" ahora pertenece a la categoría "$categoria".');
  }
}
