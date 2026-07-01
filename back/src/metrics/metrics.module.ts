import { Module } from '@nestjs/common';
import { collectDefaultMetrics } from 'prom-client';
import { MetricsController } from './metrics.controller';

// collectDefaultMetrics() в конструкторе модуля включает сборку стандартных
// метрик Node.js-процесса: heap, event loop lag, GC, активные handles.
// Эти метрики появляются автоматически в дефолтном реестре, никакой явной
// регистрации не требуется.

@Module({
  controllers: [MetricsController],
})
export class MetricsModule {
  constructor() {
    collectDefaultMetrics();
  }
}
