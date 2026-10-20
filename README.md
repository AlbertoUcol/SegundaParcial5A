# Gestión de Productos

Aplicación Flutter para consultar y gestionar un catálogo de productos con una
interfaz moderna que combina tonos morados y verdes.

## Ejecutar

```shell
flutter pub get
flutter run
```

## Accesos de demostración

| Usuario | Contraseña |
| --- | --- |
| `admin` | `12345` |
| `inventario` | `67890` |
| `ventas` | `54321` |
| `bodega` | `24680` |

Los accesos son locales y solo sirven para demostración. El catálogo se obtiene
de FakeStoreAPI; los cambios hechos desde la aplicación no se persisten en ese
servicio.

Para cerrar la sesión, usa el botón de salida de la barra superior del catálogo.
La aplicación vuelve al login y elimina las pantallas anteriores de la pila de
navegación.
