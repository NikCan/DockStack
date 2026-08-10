# k8s/optional — необязательные манифесты (soft, вне обязательного DoD)

Эти манифесты **не** применяются командой `kubectl apply -f k8s/` (она нерекурсивна и
в подпапки не заходит). Применяй их вручную и только после установки нужных
зависимостей — иначе `kubectl apply` упадёт на отсутствующих CRD/компонентах.

| Файл | Зависимость | Урок |
|---|---|---|
| `backend-hpa.yaml` | Metrics Server (`kubectl top pods` работает) | HPA |
| `backend-servicemonitor.yaml` | CRD `ServiceMonitor` из `kube-prometheus-stack` | Мониторинг |

Порядок и подробности — в self-study по мониторингу и автоскейлингу
(`full-course/hometasks/06/03-k8s-monitoring-scaling-self-study.mdx`).
