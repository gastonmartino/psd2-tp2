/**
 * particulas
 *
 * Sistema de partículas en un espacio 3D.
 * Las partículas nacen sobre la superficie de una esfera centrada en el
 * lienzo y se alejan de ella siguiendo una dirección radial.
 */

final int PARTICULAS_INICIALES = 500;
final int PARTICULAS_POR_FOTOGRAMA = 500;
final int MAXIMO_DE_PARTICULAS = 12000;
final int TIEMPO_HASTA_LA_ESFERA = 500;
final int DURACION_DE_VIBRACION = 1500;
final int FOTOGRAMAS_POR_SEGUNDO = 30;
final float RADIO_DE_LA_ESFERA = 61;
final float DISTANCIA_MAXIMA = 1430;
final int CANTIDAD_DE_COMETAS = 8;
final int LONGITUD_TRAYECTORIA = 128;
final float FUERZA_DEL_CAMPO_VECTORIAL = 0.035;
final float INFLUENCIA_TANGENCIAL = 0.75;
final float DISTANCIA_INICIO_DEL_COLOR = 260;
final float DISTANCIA_DE_CAPTURA = 24;
final float RADIO_DE_ORBITA_DE_PARTICULA = 12;
final int DURACION_DE_ORBITA_DE_PARTICULA = 3000;
final int DURACION_DE_TRANSICION = 2000;
final int CANTIDAD_DE_AGLOMERADOS = 9;

SistemaDeParticulas sistema;
ArrayList<Cometa> cometas;
PImage imagenDeReferencia;
color colorDeFondoDeImagen;
color[] coloresDeLineas;
PVector[] centrosDeAglomerados;
boolean teclaCPresionada = false;
float intensidadDelModoImagen = 0;
int instanteDeLaUltimaTransicion;
float rotacionX = 0;
float rotacionY = 0;

void setup() {
  size(1920, 1080, P3D);
  surface.setTitle("particulas - esfera 3D");
  frameRate(60);
  sphereDetail(5);

  imagenDeReferencia = loadImage("imagen01.jpg");
  colorDeFondoDeImagen = obtenerColorDeFondo(imagenDeReferencia);
  inicializarColoresDeLasLineas();
  inicializarCentrosDeAglomerados();

  sistema = new SistemaDeParticulas(PARTICULAS_INICIALES);
  cometas = new ArrayList<Cometa>();
  for (int i = 0; i < CANTIDAD_DE_COMETAS; i++) {
    cometas.add(new Cometa(i));
  }
  instanteDeLaUltimaTransicion = millis();
}

void draw() {
  actualizarTransicionDelModoImagen();
  color colorDeFondo = lerpColor(color(4, 10, 35),
                                 colorDeFondoDeImagen,
                                 intensidadDelModoImagen);
  background(colorDeFondo);

  // El movimiento de cámara permite percibir la profundidad del sistema.
  translate(width * 0.61, height * 0.61, -100);
  rotateX(rotacionX);
  rotateY(rotacionY);
  rotacionX += 0.0055;
  rotacionY += 0.0045;

  // Una luz ambiental muy tenue conserva el fondo oscuro.
  ambientLight(8, 12, 35);

  sistema.actualizar();
  sistema.dibujar(intensidadDelModoImagen);

  for (Cometa cometa : cometas) {
    cometa.actualizar();
    cometa.dibujar(intensidadDelModoImagen);
  }
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    teclaCPresionada = true;
  }
}

void keyReleased() {
  if (key == 'c' || key == 'C') {
    teclaCPresionada = false;
  }
}

void actualizarTransicionDelModoImagen() {
  int ahora = millis();
  float paso = (ahora - instanteDeLaUltimaTransicion) / float(DURACION_DE_TRANSICION);
  instanteDeLaUltimaTransicion = ahora;

  if (teclaCPresionada) {
    intensidadDelModoImagen = min(1, intensidadDelModoImagen + paso);
  } else {
    intensidadDelModoImagen = max(0, intensidadDelModoImagen - paso);
  }
}

color obtenerColorDeFondo(PImage imagen) {
  if (imagen == null) {
    return color(245, 243, 240);
  }

  float rojo = 0;
  float verde = 0;
  float azul = 0;
  int cantidadDeMuestras = 0;
  int pasoX = max(1, imagen.width / 24);
  int pasoY = max(1, imagen.height / 24);

  // Se toman muestras del borde, donde predomina el papel de fondo.
  for (int x = 0; x < imagen.width; x += pasoX) {
    color muestraSuperior = imagen.get(x, 2);
    color muestraInferior = imagen.get(x, imagen.height - 3);
    rojo += red(muestraSuperior) + red(muestraInferior);
    verde += green(muestraSuperior) + green(muestraInferior);
    azul += blue(muestraSuperior) + blue(muestraInferior);
    cantidadDeMuestras += 2;
  }

  for (int y = 0; y < imagen.height; y += pasoY) {
    color muestraIzquierda = imagen.get(2, y);
    color muestraDerecha = imagen.get(imagen.width - 3, y);
    rojo += red(muestraIzquierda) + red(muestraDerecha);
    verde += green(muestraIzquierda) + green(muestraDerecha);
    azul += blue(muestraIzquierda) + blue(muestraDerecha);
    cantidadDeMuestras += 2;
  }

  return color(rojo / cantidadDeMuestras,
               verde / cantidadDeMuestras,
               azul / cantidadDeMuestras);
}

void inicializarColoresDeLasLineas() {
  // Paleta tomada de los trazos grises, azules, rojos y verdes de la imagen.
  coloresDeLineas = new color[] {
    color(48, 49, 53),
    color(76, 72, 78),
    color(55, 73, 98),
    color(103, 84, 87),
    color(108, 105, 68),
    color(80, 94, 82)
  };
}

void inicializarCentrosDeAglomerados() {
  centrosDeAglomerados = new PVector[CANTIDAD_DE_AGLOMERADOS];
  for (int i = 0; i < CANTIDAD_DE_AGLOMERADOS; i++) {
    float posicionX = map(i, 0, CANTIDAD_DE_AGLOMERADOS - 1,
                          -width * random(0.2, 0.5), width * random(0.1, 0.6));
    centrosDeAglomerados[i] = new PVector(posicionX + random(-18, 41), 0, 0);
  }
}

color obtenerColorDeLineaAleatorio() {
  return coloresDeLineas[int(random(coloresDeLineas.length))];
}

Cometa obtenerCometaMasCercano(PVector punto) {
  Cometa cometaMasCercano = null;
  float menorDistancia = Float.MAX_VALUE;

  for (Cometa cometa : cometas) {
    float distancia = cometa.distanciaALaTrayectoria(punto);
    if (distancia < menorDistancia) {
      menorDistancia = distancia;
      cometaMasCercano = cometa;
    }
  }

  return cometaMasCercano;
}
