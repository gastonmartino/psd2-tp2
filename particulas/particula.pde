class Particula {
  PVector posicion;
  PVector posicionInicial;
  PVector direccion;
  PVector velocidad;
  float tamano;
  float brillo;
  float faseDeVibracion;
  int instanteDeNacimiento;
  boolean seEstaAlejando;

  Particula() {
    reiniciar();
  }

  void reiniciar() {
    // Una dirección aleatoria define el punto de llegada sobre la esfera.
    direccion = PVector.random3D();
    posicionInicial = PVector.mult(direccion, RADIO_DE_LA_ESFERA);

    // Todas las partículas comienzan en el centro del lienzo.
    posicion = new PVector(0, 0, 0);

    // La velocidad radial se activa después de llegar y vibrar en la esfera.
    velocidad = new PVector();
    tamano = random(0.5, 1.8);
    brillo = random(200, 255);
    faseDeVibracion = random(TWO_PI);
    instanteDeNacimiento = millis();
    seEstaAlejando = false;
  }

  void actualizar() {
    int edad = millis() - instanteDeNacimiento;
    int finalDelPeriodoDeVibracion = TIEMPO_HASTA_LA_ESFERA + DURACION_DE_VIBRACION;

    if (!seEstaAlejando && edad <= TIEMPO_HASTA_LA_ESFERA) {
      // La partícula viaja suavemente desde el centro hasta la esfera.
      float progreso = edad / float(TIEMPO_HASTA_LA_ESFERA);
      progreso = progreso * progreso * (3.0 - 2.0 * progreso);
      posicion = PVector.lerp(new PVector(0, 0, 0), posicionInicial, progreso);
    } else if (!seEstaAlejando && edad <= finalDelPeriodoDeVibracion) {
      // Vibración pequeña alrededor de la superficie, sin deriva acumulada.
      float tiempo = (edad - TIEMPO_HASTA_LA_ESFERA) * 0.004 + faseDeVibracion;
      PVector vibracion = new PVector(
        sin(tiempo) * 3.0,
        cos(tiempo * 1.21) * 3.0,
        sin(tiempo * 0.83) * 3.0
      );
      posicion = PVector.add(posicionInicial, vibracion);
    } else {
      if (!seEstaAlejando) {
        seEstaAlejando = true;
        velocidad = PVector.mult(direccion, random(2.35, 3.7));
      }

      posicion.add(velocidad);
      velocidad.mult(1.002);
    }
  }

  boolean estaFueraDeLaEscena() {
    return posicion.mag() > DISTANCIA_MAXIMA;
  }

  void dibujar() {
    pushMatrix();
    translate(posicion.x, posicion.y, posicion.z);

    // Un halo grande y suave más un núcleo pequeño forman el brillo.
    noStroke();
    emissive(255, 255, 255);
    fill(255, brillo * 0.08);
    sphere(tamano * 4.5);

    fill(255, brillo);
    sphere(tamano);
    popMatrix();
  }
}
