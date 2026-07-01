import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';
import { register } from 'prom-client';
import { ApiExcludeController } from '@nestjs/swagger';

// Эндпоинт /metrics для hw5: Prometheus сам приходит сюда раз в 15 секунд
// и забирает текстовый snapshot всех зарегистрированных метрик.
// Контракт: ответ должен иметь Content-Type 'text/plain; version=0.0.4'
// и тело в формате Prometheus exposition (строки `# HELP`, `# TYPE`,
// затем сами метрики). prom-client это всё формирует сам.

@ApiExcludeController()
@Controller('metrics')
export class MetricsController {
  @Get()
  async getMetrics(@Res() res: Response): Promise<void> {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  }
}
