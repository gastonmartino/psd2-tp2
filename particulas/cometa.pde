class Cometa {
  PVector posicion;
  PVector ejeHorizontal;
  PVector ejeVertical;
  ArrayList<PVector> trayectoria;
  float angulo;
  float velocidadAngular;
  float radioOrbita;
  float profundidadOrbita;
  float tamano;
  float fase;
  PVector direccionOrbital;
  color colorDeFuego;
  float tonoDeGris;
  color colorDeLineaDeImagen;

  Cometa(int numero) {
    trayectoria = new ArrayList<PVector>();

    // Dos ejes perpendiculares definen un plano orbital distinto para cada cometa.
    ejeHorizontal = PVector.random3D();
    PVector ejeAuxiliar = PVector.random3D();
    ejeVertical = ejeHorizontal.cross(ejeAuxiliar);
    while (ejeVertical.magSq() < 0.01) {
      ejeAuxiliar = PVector.random3D();
      ejeVertical = ejeHorizontal.cross(ejeAuxiliar);
    }
    ejeVertical.normalize();

    angulo = TWO_PI * numero / float(CANTIDAD_DE_COMETAS) + random(-0.15, 0.15);
    velocidadAngular = random(0.006, 0.014) * (numero % 2 == 0 ? 1 : -1);
    radioOrbita = RADIO_DE_LA_ESFERA * random(4.3, 6.8);
    profundidadOrbita = random(0.65, 1.0);
    tamano = random(1.0, 1.5);
    fase = random(TWO_PI);
    colorDeFuego = color(255, random(75, 165), random(8, 35));
    tonoDeGris = random(25, 70);
    colorDeLineaDeImagen = colorDeLineaRojaAleatorio();

    posicion = calcularPosicion();
    direccionOrbital = calcularDireccionOrbital();
    for (int i = 0; i < 28; i++) {
      trayectoria.add(posicion.copy());
    }
  }

  PVector calcularPosicion() {
    float radioVertical = radioOrbita * profundidadOrbita;
    PVector horizontal = PVector.mult(ejeHorizontal, cos(angulo) * radioOrbita);
    PVector vertical = PVector.mult(ejeVertical, sin(angulo) * radioVertical);
    return PVector.add(horizontal, vertical);
  }

  PVector calcularDireccionOrbital() {
    float radioVertical = radioOrbita * profundidadOrbita;
    PVector horizontal = PVector.mult(ejeHorizontal, -sin(angulo) * radioOrbita);
    PVector vertical = PVector.mult(ejeVertical, cos(angulo) * radioVertical);
    PVector tangente = PVector.add(horizontal, vertical);
    tangente.mult(velocidadAngular < 0 ? -1 : 1);
    tangente.normalize();
    return tangente;
  }

  void actualizar() {
    angulo += velocidadAngular;
    posicion = calcularPosicion();
    direccionOrbital = calcularDireccionOrbital();
    trayectoria.add(0, posicion.copy());

    while (trayectoria.size() > LONGITUD_TRAYECTORIA) {
      trayectoria.remove(trayectoria.size() - 1);
    }
  }

  float distanciaALaTrayectoria(PVector punto) {
    float menorDistancia = PVector.dist(punto, posicion);
    for (PVector puntoDeLaTrayectoria : trayectoria) {
      menorDistancia = min(menorDistancia, PVector.dist(punto, puntoDeLaTrayectoria));
    }
    return menorDistancia;
  }

  PVector calcularCampoEn(PVector punto) {
    PVector haciaElCometa = PVector.sub(posicion, punto);
    if (haciaElCometa.magSq() > 0.0001) {
      haciaElCometa.normalize();
    }

    // El campo combina atracción hacia el cometa y el sentido de su órbita.
    PVector campo = PVector.add(haciaElCometa,
                                PVector.mult(direccionOrbital, INFLUENCIA_TANGENCIAL));
    campo.normalize();
    return campo;
  }

  color obtenerColorDeFuego() {
    return colorDeFuego;
  }

  void dibujar(float intensidadDelModoImagen) {
    if (intensidadDelModoImagen < 1) {
      dibujarComoCometaLuminoso(1.0 - intensidadDelModoImagen);
    }
    if (intensidadDelModoImagen > 0) {
      dibujarComoLineaConstante(intensidadDelModoImagen);
    }
  }

  void dibujarComoCometaLuminoso(float opacidad) {
    blendMode(ADD);

    // La cola se dibuja desde un naranja intenso hasta un rojo transparente.
    noFill();
    for (int i = 1; i < trayectoria.size(); i++) {
      PVector anterior = trayectoria.get(i - 1);
      PVector punto = trayectoria.get(i);
      float progreso = i / float(trayectoria.size());
      stroke(255, 150 - progreso * 110, 25, (220 - progreso * 190) * opacidad);
      strokeWeight(max(1, tamano * (1.0 - progreso) * 0.65));
      line(anterior.x, anterior.y, anterior.z, punto.x, punto.y, punto.z);
    }

    pushMatrix();
    translate(posicion.x, posicion.y, posicion.z);
    float pulso = 1.0 + sin(frameCount * 0.12 + fase) * 0.15;

    noStroke();
    emissive(255, 80, 10);
    fill(255, 50, 5, 35 * opacidad);
    sphere(tamano * 3.8 * pulso);

    emissive(255, 210, 80);
    fill(255, 245, 190, 255 * opacidad);
    sphere(tamano * pulso);
    popMatrix();

    blendMode(BLEND);
  }

  void dibujarComoLineaConstante(float opacidad) {
    noFill();
    for (int i = 1; i < trayectoria.size(); i++) {
      PVector anterior = trayectoria.get(i - 1);
      PVector punto = trayectoria.get(i);
      float progreso = i / float(trayectoria.size());
      stroke(255, 100 - progreso * 110, 15, (220 - progreso * 190) * opacidad);
      strokeWeight(max(1, tamano * (1.0 - progreso) * 0.65));
      line(anterior.x, anterior.y, anterior.z, punto.x, punto.y, punto.z);
    }

    pushMatrix();
    translate(posicion.x, posicion.y, posicion.z);
    float pulso = 0.3 + sin(frameCount * 0.12 + fase) * 0.15;

    noStroke();
    emissive(255, 80, 10);
    fill(255, 50, 5, 35 * opacidad);
    sphere(tamano * 3.8 * pulso);

    emissive(255, 210, 80);
    fill(255, 245, 190, 255 * opacidad);
    sphere(tamano * pulso);
    popMatrix();
  }


  color colorDeLineaRojaAleatorio() {
    color[] rojos = {
      color(105, 48, 58),
      color(130, 62, 70),
      color(155, 78, 82),
      color(112, 55, 67),
      color(175, 96, 95)
    };
    return rojos[int(random(rojos.length))];
  }
}
