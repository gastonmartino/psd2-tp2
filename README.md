### Programación de Sistemas Dinámicos 2 (PSD2)
# Comunicación Interactiva y  Arquitectura de Software con IA
Ejercicio de programación introductorio para evaluar la integración de las herramientas de IA dentro de plataformas para escribir código asistidas por IA.

> Trabajo práctico #2 - Segundo cuatrimestre, 2026 - MAE, UNTREF

<br>

# Introducción y propósito
Los sistemas generativos basados en caminantes, sistemas de partículas y campos vectoriales constituyen estrategias fundamentales del código creativo. El objetivo de este trabajo es utilizar estas técnicas como punto de partida para desarrollar una propuesta original, empleando herramientas de Inteligencia Artificial como apoyo para investigar, planificar y expandir las posibilidades del proyecto. No se espera la reproducción de los ejemplos vistos en clase, sino la construcción de un sistema con identidad propia.

<br>

## Partículas 3D

`particulas` es un sketch de Processing que genera un sistema de partículas luminosas en un espacio 3D.

Cada tanda de partículas:

1. Nace en el centro del canvas.
2. Viaja durante aproximadamente `500 ms` hasta un punto de la superficie de una esfera.
3. Permanece vibrando alrededor de esa posición durante aproximadamente `1500 ms`.
4. Se dispara radialmente hacia afuera.
5. Desaparece al superar la distancia máxima definida en el programa.

El fondo es azul oscuro y las partículas se dibujan en blanco utilizando una mezcla aditiva para producir un efecto luminoso. La cámara rota suavemente para facilitar la percepción del espacio 3D.

## Modo de la imagen

Mientras se mantiene presionada la tecla **C** —mayúscula o minúscula— se activa un modo alternativo inspirado en la imagen `particulas/data/imagen01.jpg`:

- El fondo transiciona gradualmente hacia el color del fondo de la imagen.
- Los cometas dejan de mostrar una estela degradada y se dibujan como líneas curvas continuas en tonalidades de rojo.
- Las partículas que todavía están sobre la esfera se agrupan sobre el eje horizontal y vibran mediante ruido Perlin (`noise()`).
- Las partículas del sistema se dibujan como caminantes, usando una paleta de colores tomada de las líneas de la imagen.

Al soltar la tecla **C**, el programa vuelve gradualmente al modo normal durante aproximadamente dos segundos.

## Ubicación del sketch

El proyecto se encuentra en la carpeta:

```text
particulas/
```

El archivo principal es:

```text
particulas/particulas.pde
```

Las clases están separadas en archivos individuales:

- `particula.pde`: define el comportamiento y el dibujo de cada partícula.
- `sistemadeparticulas.pde`: administra las tandas, la actualización y la eliminación de partículas.

## Requisitos

- [Processing](https://processing.org/download) 3 o 4.
- Una computadora con soporte para el renderizador 3D de Processing.

No es necesario instalar librerías externas. El sketch utiliza únicamente funcionalidades incluidas en Processing, como `P3D`, `PVector`, `sphere()` y `blendMode()`.

## Cómo ejecutar el programa

1. Abrir Processing.
2. Seleccionar **File → Open** y abrir `particulas/particulas.pde`.
3. Verificar que los archivos `particula.pde` y `sistemadeparticulas.pde` estén dentro de la misma carpeta del sketch.
4. Pulsar el botón **Run** o utilizar **Sketch → Run**.

Processing cargará automáticamente los archivos `.pde` que forman parte de la carpeta del proyecto.

## Parámetros principales

Los parámetros se encuentran al comienzo de `particulas.pde`:

```java
PARTICULAS_INICIALES       // cantidad de partículas de la primera tanda
PARTICULAS_POR_FOTOGRAMA   // cantidad de partículas de las tandas siguientes
MAXIMO_DE_PARTICULAS       // límite de partículas activas
TIEMPO_HASTA_LA_ESFERA    // tiempo de viaje desde el centro, en milisegundos
DURACION_DE_VIBRACION     // duración de la vibración, en milisegundos
RADIO_DE_LA_ESFERA         // radio de la esfera de destino
DISTANCIA_MAXIMA           // distancia a partir de la cual una partícula desaparece
```
