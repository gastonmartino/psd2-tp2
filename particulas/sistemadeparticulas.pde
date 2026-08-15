class SistemaDeParticulas {
  ArrayList<Particula> particulas;
  int instanteDeLaUltimaTanda;

  SistemaDeParticulas(int cantidadInicial) {
    particulas = new ArrayList<Particula>();
    emitirTanda(cantidadInicial);
    instanteDeLaUltimaTanda = millis();
  }

  void emitirTanda(int cantidad) {
    for (int i = 0; i < cantidad; i++) {
      if (particulas.size() < MAXIMO_DE_PARTICULAS) {
        particulas.add(new Particula());
      }
    }
  }

  void actualizar() {
    // Cada medio segundo se genera una nueva tanda sobre la esfera.
    if (millis() - instanteDeLaUltimaTanda >= DURACION_DE_VIBRACION) {
      emitirTanda(PARTICULAS_POR_FOTOGRAMA);
      instanteDeLaUltimaTanda = millis();
    }

    // Las partículas que ya se alejaron demasiado abandonan el sistema.
    for (int i = particulas.size() - 1; i >= 0; i--) {
      Particula particula = particulas.get(i);
      particula.actualizar();
      if (particula.estaMuerta() || particula.estaFueraDeLaEscena()) {
        particulas.remove(i);
      }
    }
  }

  void dibujar(float intensidadDelModoImagen) {
    blendMode(ADD);
    for (Particula particula : particulas) {
      particula.dibujar(intensidadDelModoImagen);
    }
    blendMode(BLEND);
  }
}
