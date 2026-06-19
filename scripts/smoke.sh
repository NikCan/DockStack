#!/usr/bin/env bash
# Smoke-проверка задеплоенного стека для hw4 — лёгкий read-only health check.
#
# Используется в job'е `verify` пайплайна и доступна локально через `make smoke-deployed`.
# В отличие от `make e2e-deployed` (Playwright + reset todos) — НЕ мутирует данные:
# только проверяет, что /api/health отвечает 200 со status=ok и что фронт отдаёт HTML.
#
# Требует переменную окружения E2E_BASE_URL (вида https://your-domain.example).
# Обычно подгружается из .env.production.e2e через `make smoke-deployed`.

set -euo pipefail

: "${E2E_BASE_URL:?E2E_BASE_URL must be set (e.g. https://your-domain.example)}"

# Нормализуем trailing slash — на всякий случай.
BASE="${E2E_BASE_URL%/}"

echo "→ GET ${BASE}/api/health"
HEALTH=$(curl -sSf --max-time 10 "${BASE}/api/health")
echo "  ${HEALTH}"
echo "${HEALTH}" | grep -q '"status":"ok"' || {
  echo "✗ /api/health did not return status=ok"
  exit 1
}

echo "→ GET ${BASE}/"
INDEX=$(curl -sSf --max-time 10 "${BASE}/")
echo "${INDEX}" | grep -qi '<title' || {
  echo "✗ frontend did not return HTML (no <title> tag)"
  exit 1
}

echo "✓ smoke checks passed"
