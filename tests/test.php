<?php
require_once __DIR__ . '/../src/functions.php';

$errores = [];

if (suma(2, 3) !== 5) {
    $errores[] = 'La función suma() no devuelve el resultado esperado.';
}

if (estadoAplicacion() !== 'Aplicación cintaspaniagua operativa') {
    $errores[] = 'La función estadoAplicacion() no devuelve el estado esperado.';
}

if ($errores !== []) {
    foreach ($errores as $error) {
        fwrite(STDERR, $error . PHP_EOL);
    }
    exit(1);
}

fwrite(STDOUT, "Pruebas básicas de cintaspaniagua correctas." . PHP_EOL);
exit(0);
