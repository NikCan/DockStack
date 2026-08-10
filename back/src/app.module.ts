import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TodosModule } from './todos/todos.module';
import { Todo } from './todos/todo.entity';
import { TestResetModule } from './test-reset/test-reset.module';
import { HealthModule } from './health/health.module';
import { ReadinessModule } from './readiness/readiness.module';
import { MetricsModule } from './metrics/metrics.module';
import { MetricsMiddleware } from './metrics/metrics.middleware';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        host: config.get<string>('DB_HOST'),
        port: parseInt(config.get<string>('DB_PORT') ?? '5432', 10),
        username: config.get<string>('DB_USER'),
        password: config.get<string>('DB_PASSWORD'),
        database: config.get<string>('DB_NAME'),
        entities: [Todo],
        synchronize: true,
      }),
    }),
    TodosModule,
    TestResetModule,
    HealthModule,
    ReadinessModule,
    MetricsModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    // Меряем все маршруты, кроме служебных: /metrics (self-probe),
    // /health (liveness) и /ready (readiness) — это не пользовательский трафик,
    // и Kubernetes-пробы дёргают их часто, засоряя гистограмму времени ответа.
    consumer
      .apply(MetricsMiddleware)
      .exclude('metrics', 'health', 'ready')
      .forRoutes('*');
  }
}
