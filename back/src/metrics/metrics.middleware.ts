import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { Counter, Histogram } from 'prom-client';

// Кастомные метрики hw5: фиксируем время ответа и количество HTTP-запросов
// в разрезе method/route/status_code. Эти два объекта живут в дефолтном
// реестре prom-client; их же отдаёт /metrics через register.metrics().
//
// Buckets подобраны под «обычное web-API»: основная масса запросов
// до 0.5s, чем выше — тем интереснее с точки зрения медленных хвостов.

export const httpRequestDuration = new Histogram({
  name: 'http_response_time_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],
});

export const httpRequestsTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code'],
});

interface ExpressRoute {
  path: string;
}

@Injectable()
export class MetricsMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction): void {
    const end = httpRequestDuration.startTimer();

    res.on('finish', () => {
      // req.route появляется ПОСЛЕ матчинга роута Express'ом — если запрос ушёл
      // в 404 (роут не найден), req.route будет undefined; падаем обратно на req.path.
      const route = (req.route as ExpressRoute | undefined)?.path ?? req.path;
      const labels = {
        method: req.method,
        route,
        status_code: res.statusCode,
      };
      end(labels);
      httpRequestsTotal.inc(labels);
    });

    next();
  }
}
