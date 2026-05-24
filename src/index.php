<?php

require_once __DIR__ . '/functions.php';

$resultado = suma(3, 2);
$estado = estadoAplicacion();

?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>CI/CD cintaspaniagua</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <main class="container">
        <span class="badge">Estado: <?= htmlspecialchars($estado) ?></span>

        <h1>Pipeline CI/CD - cintaspaniagua</h1>

        <p>Aplicación PHP desplegada automáticamente con Jenkins y Docker.</p>

        <div class="result">
            Resultado de suma(3, 2): <?= htmlspecialchars((string) $resultado) ?>
        </div>

        <div class="footer">
            GitHub → Jenkins → Tests → Docker → Docker Hub → Despliegue
        </div>
    </main>
</body>
</html>