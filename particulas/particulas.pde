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

SistemaDeParticulas sistema;
float rotacionX = 0;
float rotacionY = 0;

void setup() {
  size(960, 720, P3D);
  surface.setTitle("particulas - esfera 3D");
  frameRate(60);
  sphereDetail(5);

  sistema = new SistemaDeParticulas(PARTICULAS_INICIALES);
}

void draw() {
  background(4, 10, 35);

  // El movimiento de cámara permite percibir la profundidad del sistema.
  translate(width * 0.5, height * 0.5, -80);
  rotateX(rotacionX);
  rotateY(rotacionY);
  rotacionX += 0.0015;
  rotacionY += 0.0025;

  // Una luz ambiental muy tenue conserva el fondo oscuro.
  ambientLight(8, 12, 35);

  sistema.actualizar();
  sistema.dibujar();
}
