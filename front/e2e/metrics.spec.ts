import { expect, request as pwRequest, test } from '@playwright/test';

// Тесты hw5 — проверяют, что backend отдаёт метрики в формате Prometheus
// и что кастомная middleware действительно записывает время ответа.
// Гоняется и локально (`make e2e`), и против VPS (`make e2e-deployed`).

const API = (process.env.E2E_API_URL ?? 'http://localhost:3000').replace(
  /\/$/,
  '',
);

test('exposes /metrics in Prometheus text format', async () => {
  const ctx = await pwRequest.newContext();
  const res = await ctx.get(`${API}/metrics`);
  expect(res.status()).toBe(200);
  expect(res.headers()['content-type'] ?? '').toMatch(/text\/plain/);

  const body = await res.text();
  expect(body).toContain('# HELP');
  expect(body).toContain('# TYPE');

  await ctx.dispose();
});

test('exposes default Node.js process metrics', async () => {
  const ctx = await pwRequest.newContext();
  const res = await ctx.get(`${API}/metrics`);
  const body = await res.text();

  expect(body).toMatch(/nodejs_heap_size_used_bytes\s/);
  expect(body).toMatch(/process_cpu_user_seconds_total\s/);

  await ctx.dispose();
});

test('records http_response_time_seconds for API traffic', async () => {
  const ctx = await pwRequest.newContext();

  // Дёргаем настоящий роут чтобы middleware записал замер.
  await ctx.get(`${API}/todos`);
  await ctx.get(`${API}/todos`);

  const res = await ctx.get(`${API}/metrics`);
  const body = await res.text();

  // Ищем счётчик histogram'а: имя_count{лейблы} число.
  // Хотя бы один матч с method="GET" должен быть после двух GET-запросов.
  expect(body).toMatch(
    /http_response_time_seconds_count\{[^}]*method="GET"[^}]*\}\s+\d+/,
  );

  await ctx.dispose();
});

test('excludes /metrics and /health from histogram (self-probe protection)', async () => {
  const ctx = await pwRequest.newContext();

  // Стучимся в /metrics и /health дважды — ни один из них не должен
  // появиться в самом histogram'е, иначе middleware «измеряет себя».
  await ctx.get(`${API}/metrics`);
  await ctx.get(`${API}/health`);
  await ctx.get(`${API}/metrics`);
  await ctx.get(`${API}/health`);

  const res = await ctx.get(`${API}/metrics`);
  const body = await res.text();

  expect(body).not.toMatch(
    /http_response_time_seconds_count\{[^}]*route="\/metrics"/,
  );
  expect(body).not.toMatch(
    /http_response_time_seconds_count\{[^}]*route="\/health"/,
  );

  await ctx.dispose();
});
