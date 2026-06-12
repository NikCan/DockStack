import { expect, test, request } from '@playwright/test';
import { resetTodos } from './helpers';

const API = process.env.E2E_API_URL ?? 'http://localhost:3000';

test.beforeEach(async () => {
  await resetTodos();
});

test('rejects creation when maxTodos limit is reached', async () => {
  // Default committed config is { "maxTodos": 5 }.
  // Если этот тест падает с 500 на первом же POST — скорее всего bind-mount
  // ./app-config:/app/config:ro не настроен и back не может прочитать конфиг.
  const ctx = await request.newContext();

  for (let i = 1; i <= 5; i++) {
    const res = await ctx.post(`${API}/todos`, { data: { title: `todo ${i}` } });
    expect(res.status(), `creating todo #${i} should succeed`).toBe(201);
  }

  const overflow = await ctx.post(`${API}/todos`, { data: { title: 'overflow' } });
  expect(overflow.status()).toBe(400);

  const body = (await overflow.json()) as { message?: string };
  expect(body.message ?? '').toMatch(/limit/i);

  await ctx.dispose();
});
