#!/usr/bin/env bash
set -e

# Variables de entorno del proyecto
DOCKERHUB_USER="raulcintas"
IMAGE_NAME="app-ci-cintaspaniagua"
IMAGE_VERSION="${IMAGE_VERSION:-latest}"
REPORT_FILE="reports/test-report.txt"
SSH_HOST="${SSH_HOST:-}"
SSH_USER="${SSH_USER:-}"
SSH_PATH="${SSH_PATH:-/var/www/cintaspaniagua}"

echo "[INFO] Ejecutando análisis estático..."
php -l src/functions.php
php -l src/index.php
php -l tests/test.php

echo "[INFO] Análisis estático completado."
echo "[INFO] Ejecutando pruebas..."
mkdir -p reports
set +e
php tests/test.php > "${REPORT_FILE}" 2>&1
TEST_STATUS=$?
set -e

echo "TEST_EXIT_CODE=${TEST_STATUS}" >> "${REPORT_FILE}"

if [[ "${TEST_STATUS}" -ne 0 ]]; then
  echo "[ERROR] Las pruebas fallaron. Revisa el reporte: ${REPORT_FILE}"
  cat "${REPORT_FILE}"
  exit "${TEST_STATUS}"
fi

echo "[INFO] Pruebas completadas correctamente."

echo "[INFO] Reporte generado en ${REPORT_FILE}"
cat "${REPORT_FILE}"

echo "[INFO] Construyendo imágenes Docker..."
docker build -f Dockerfile.php82 -t "${IMAGE_NAME}:${IMAGE_VERSION}-php82" .
docker build -f Dockerfile.php83 -t "${IMAGE_NAME}:${IMAGE_VERSION}-php83" .

echo "[INFO] Imágenes Docker construidas."


echo "[INFO] Iniciando sesión en Docker Hub..."
echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USER}" --password-stdin

echo "[INFO] Publicando imágenes en Docker Hub..."
docker push "${IMAGE_NAME}:${IMAGE_VERSION}-php82"
docker push "${IMAGE_NAME}:${IMAGE_VERSION}-php83"

echo "[INFO] Publicación completada."

if [[ -n "${SSH_HOST}" && -n "${SSH_USER}" ]]; then
  echo "[INFO] Desplegando por SSH en ${SSH_HOST}..."
  rsync -avz --delete \
    --exclude '.git' \
    --exclude 'vendor' \
    --exclude 'node_modules' \
    ./ "${SSH_USER}@${SSH_HOST}:${SSH_PATH}/"
  echo "[INFO] Despliegue SSH completado."
else
  echo "[INFO] Despliegue SSH omitido (variables SSH_HOST/SSH_USER no configuradas)."
fi

echo "[INFO] Flujo completado."
