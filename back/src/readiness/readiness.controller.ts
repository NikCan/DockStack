import {
  Controller,
  Get,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

// Readiness-эндпоинт для Kubernetes readinessProbe (hw6).
//
// Разница с /health:
//   /health  (livenessProbe)  — «процесс жив?». Лёгкая проверка без похода в БД.
//                               Провал → Kubernetes ПЕРЕЗАПУСКАЕТ контейнер.
//   /ready   (readinessProbe) — «готов принять трафик?». Проверяет зависимость —
//                               доступна ли БД. Провал → Kubernetes убирает Pod из
//                               endpoints Service (трафик не идёт), но НЕ перезапускает.
//
// Такое разделение нужно, чтобы недоступность БД не вызывала каскадный рестарт
// всех Pod-ов (перезапуск бэкенда БД не чинит), а лишь временно выводил Pod
// из ротации до восстановления соединения.
@ApiExcludeController()
@Controller('ready')
export class ReadinessController {
  constructor(
    @InjectDataSource() private readonly dataSource: DataSource,
  ) {}

  @Get()
  async getReady(): Promise<{ status: 'ready' }> {
    try {
      await this.dataSource.query('SELECT 1');
    } catch {
      // 503 → Pod исключается из endpoints Service до восстановления БД.
      throw new ServiceUnavailableException({ status: 'not-ready' });
    }
    return { status: 'ready' };
  }
}
