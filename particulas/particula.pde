class Particula {
  PVector posicion;
  PVector posicionAnterior;
  PVector posicionInicial;
  PVector posicionDeAglomerado;
  PVector direccion;
  PVector velocidad;
  float tamano;
  float brillo;
  float faseDeVibracion;
  int instanteDeNacimiento;
  boolean seEstaAlejando;
  boolean estaOrbitandoCometa;
  Cometa cometaObjetivo;
  PVector ejeDeOrbitaA;
  PVector ejeDeOrbitaB;
  float anguloDeOrbita;
  float velocidadDeOrbita;
  float semillaDeRuido;
  int indiceDeAglomerado;
  color colorActual;
  color colorDeLinea;
  int instanteDeCaptura;
  boolean estaMuerta;

  Particula() {
    reiniciar();
  }

  void reiniciar() {
    // Una dirección aleatoria define el punto de llegada sobre la esfera.
    direccion = PVector.random3D();
    posicionInicial = PVector.mult(direccion, RADIO_DE_LA_ESFERA);

    // Todas las partículas comienzan en el centro del lienzo.
    posicion = new PVector(0, 0, 0);
    posicionAnterior = posicion.copy();

    // Cada partícula se asigna a un centro compartido sobre el eje horizontal.
    indiceDeAglomerado = int(random(CANTIDAD_DE_AGLOMERADOS));
    PVector centroDelAglomerado = centrosDeAglomerados[indiceDeAglomerado];
    posicionDeAglomerado = new PVector(
      centroDelAglomerado.x + randomGaussian() * 13,
      randomGaussian() * 5,
      randomGaussian() * 5
    );
    semillaDeRuido = random(1000);
    colorDeLinea = obtenerColorDeLineaAleatorio();

    // La velocidad radial se activa después de llegar y vibrar en la esfera.
    velocidad = new PVector();
    tamano = random(0.5, 1.8);
    brillo = random(200, 255);
    faseDeVibracion = random(TWO_PI);
    instanteDeNacimiento = millis();
    seEstaAlejando = false;
    estaOrbitandoCometa = false;
    cometaObjetivo = null;
    colorActual = color(255);
    instanteDeCaptura = 0;
    estaMuerta = false;
  }

  void actualizar() {
    posicionAnterior = posicion.copy();

    if (estaOrbitandoCometa) {
      actualizarOrbitaAlrededorDelCometa();
      return;
    }

    if (!seEstaAlejando && intensidadDelModoImagen > 0.01) {
      actualizarAglomeradoConRuido();
      return;
    }

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

      // La partícula sigue el campo del cometa cuya trayectoria está más cerca.
      cometaObjetivo = obtenerCometaMasCercano(posicion);
      if (cometaObjetivo != null) {
        PVector campo = cometaObjetivo.calcularCampoEn(posicion);
        velocidad.add(PVector.mult(campo, FUERZA_DEL_CAMPO_VECTORIAL));

        actualizarColorSegunLaDistancia(cometaObjetivo);

        if (PVector.dist(posicion, cometaObjetivo.posicion) <= DISTANCIA_DE_CAPTURA) {
          comenzarOrbitaAlrededorDelCometa();
        }
      }

      posicion.add(velocidad);
      velocidad.mult(1.002);
    }
  }

  void actualizarAglomeradoConRuido() {
    int edad = millis() - instanteDeNacimiento;
    float tiempo = millis() * 0.001;
    float ruidoX = map(noise(semillaDeRuido, tiempo * 1.7), 0, 1, -1, 1);
    float ruidoY = map(noise(semillaDeRuido + 100, tiempo * 2), 0, 1, -1, 1);
    float ruidoZ = map(noise(semillaDeRuido + 200, tiempo * 3), 0, 1, -1, 1);

    // El ruido genera bordes irregulares y evita que el aglomerado parezca una esfera perfecta.
    PVector movimiento = new PVector(ruidoX * 28, ruidoY * 25, ruidoZ * 25);
    PVector posicionDelModo = PVector.add(posicionDeAglomerado, movimiento);
    PVector posicionNormal = calcularPosicionNormal(edad);
    posicion = PVector.lerp(posicionNormal, posicionDelModo, intensidadDelModoImagen);
  }

  PVector calcularPosicionNormal(int edad) {
    if (edad <= TIEMPO_HASTA_LA_ESFERA) {
      float progreso = edad / float(TIEMPO_HASTA_LA_ESFERA);
      progreso = progreso * progreso * (3.0 - 2.0 * progreso);
      return PVector.lerp(new PVector(0, 0, 0), posicionInicial, progreso);
    }

    float tiempo = (edad - TIEMPO_HASTA_LA_ESFERA) * 0.004 + faseDeVibracion;
    PVector vibracion = new PVector(
      sin(tiempo) * 3.0,
      cos(tiempo * 1.21) * 3.0,
      sin(tiempo * 0.83) * 3.0
    );
    return PVector.add(posicionInicial, vibracion);
  }

  void actualizarColorSegunLaDistancia(Cometa cometa) {
    float distancia = PVector.dist(posicion, cometa.posicion);
    float influencia = 1.0 - constrain(distancia / DISTANCIA_INICIO_DEL_COLOR, 0, 1);
    colorActual = lerpColor(color(255), cometa.obtenerColorDeFuego(), influencia);
  }

  void comenzarOrbitaAlrededorDelCometa() {
    estaOrbitandoCometa = true;
    instanteDeCaptura = millis();
    colorActual = cometaObjetivo.obtenerColorDeFuego();
    ejeDeOrbitaA = PVector.random3D();
    PVector ejeAuxiliar = PVector.random3D();
    ejeDeOrbitaB = ejeDeOrbitaA.cross(ejeAuxiliar);

    while (ejeDeOrbitaB.magSq() < 0.01) {
      ejeAuxiliar = PVector.random3D();
      ejeDeOrbitaB = ejeDeOrbitaA.cross(ejeAuxiliar);
    }

    ejeDeOrbitaB.normalize();
    anguloDeOrbita = random(TWO_PI);
    velocidadDeOrbita = random(0.025, 0.055) * (random(1) < 0.5 ? -1 : 1);
  }

  void actualizarOrbitaAlrededorDelCometa() {
    int tiempoOrbitando = millis() - instanteDeCaptura;
    if (tiempoOrbitando >= DURACION_DE_ORBITA_DE_PARTICULA) {
      estaMuerta = true;
      return;
    }

    anguloDeOrbita += velocidadDeOrbita;
    float oscilacion = sin(frameCount * 0.08 + faseDeVibracion) * 4.0;
    float radio = RADIO_DE_ORBITA_DE_PARTICULA + oscilacion;

    PVector desplazamientoA = PVector.mult(ejeDeOrbitaA, cos(anguloDeOrbita) * radio);
    PVector desplazamientoB = PVector.mult(ejeDeOrbitaB, sin(anguloDeOrbita) * radio);
    posicion = PVector.add(cometaObjetivo.posicion,
                           PVector.add(desplazamientoA, desplazamientoB));
  }

  boolean estaFueraDeLaEscena() {
    return !estaOrbitandoCometa && posicion.mag() > DISTANCIA_MAXIMA;
  }

  boolean estaMuerta() {
    return estaMuerta;
  }

  float obtenerEscalaActual() {
    if (!estaOrbitandoCometa) {
      return 1.0;
    }

    float tiempoOrbitando = millis() - instanteDeCaptura;
    float progreso = constrain(tiempoOrbitando / float(DURACION_DE_ORBITA_DE_PARTICULA), 0, 1);
    // La reducción se concentra en la segunda mitad de la órbita.
    return 1.0 - constrain((progreso - 0.5) * 2.0, 0, 1);
  }

  void dibujar(float intensidadDelModoImagen) {
    pushMatrix();
    translate(posicion.x, posicion.y, posicion.z);

    // Un halo grande y suave más un núcleo pequeño forman el brillo.
    noStroke();
    float escala = obtenerEscalaActual() * (1.0 - intensidadDelModoImagen);
    float rojo = red(colorActual);
    float verde = green(colorActual);
    float azul = blue(colorActual);
    emissive(rojo, verde, azul);
    fill(rojo, verde, azul, brillo * 0.08 * escala);
    sphere(tamano * 4.5 * escala);

    fill(rojo, verde, azul, brillo * escala);
    sphere(tamano * escala);
    popMatrix();

    if (intensidadDelModoImagen > 0.01) {
      // En el modo de la imagen las partículas se convierten en caminantes.
      blendMode(BLEND);
      stroke(red(colorDeLinea), green(colorDeLinea), blue(colorDeLinea), 200 * intensidadDelModoImagen);
      strokeWeight(max(2.5, tamano * 6.1));
      if (abs(posicionAnterior.x - posicion.x) < width * 0.05 &&
          abs(posicionAnterior.y - posicion.y) < width * 0.05 &&
          abs(posicionAnterior.z - posicion.z) < width * 0.05) {
        line(posicionAnterior.x, posicionAnterior.y, posicionAnterior.z,
             posicion.x, posicion.y, posicion.z);
      }
      else {
        line(posicion.x, posicion.y, posicion.z,
             posicion.x, posicion.y, posicion.z);
      }
      blendMode(ADD);
    }
  }
}
