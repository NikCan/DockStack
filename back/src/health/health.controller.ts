import { Controller, Get } from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';

// Health-эндпоинт для hw4: smoke-проверка и AI-агент сверяют version
// с APP_VERSION на сервере. Подкручен из env-переменной APP_VERSION,
// которую compose прокидывает в контейнер из .env.development.compose.
// Если переменной нет — отдаём 'unknown' (не падаем).

@ApiExcludeController()
@Controller('health')
export class HealthController {
  @Get()
  getHealth(): { status: 'ok'; version: string } {
    return {
      status: 'ok',
      version: process.env.APP_VERSION ?? 'unknown',
    };
  }
}
