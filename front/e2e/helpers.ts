import { request, type APIRequestContext } from '@playwright/test';

const API = process.env.E2E_API_URL ?? 'http://localhost:3000';

// Курсовой shared-токен. То же значение прошито в back/src/test-reset/test-reset.controller.ts.
const E2E_RESET_TOKEN = 'e2e-reset-course-DevOps-2026';

/**
 * Wipe all todos via the protected reset endpoint so each test starts
 * from a clean state. Works against any environment (local or deployed).
 */
export async function resetTodos(api?: APIRequestContext) {
  const ctx = api ?? (await request.newContext({ baseURL: API }));
  const res = await ctx.post('/test/reset', {
    headers: { 'x-e2e-reset-token': E2E_RESET_TOKEN },
  });
  if (!res.ok()) {
    throw new Error(`Reset failed: ${res.status()} ${res.statusText()}`);
  }
  if (!api) await ctx.dispose();
}

export async function createTodoViaApi(
  title: string,
  description?: string,
): Promise<{ id: string; title: string; description: string | null }> {
  const ctx = await request.newContext({ baseURL: API });
  const res = await ctx.post('/todos', {
    data: { title, ...(description ? { description } : {}) },
  });
  if (!res.ok()) {
    throw new Error(`Failed to create todo: ${res.status()}`);
  }
  const json = await res.json();
  await ctx.dispose();
  return json;
}
