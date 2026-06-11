import {
  Controller,
  ForbiddenException,
  Headers,
  HttpCode,
  HttpStatus,
  Post,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ApiExcludeController } from '@nestjs/swagger';
import { Repository } from 'typeorm';
import { Todo } from '../todos/todo.entity';

// Курсовой shared-токен: знают тесты студента, AI-агент-проверяющий и бекенд.
// Менять не нужно — он одинаковый на весь поток. То же значение прошито в
// front/e2e/helpers.ts.
const E2E_RESET_TOKEN = 'e2e-reset-course-DevOps-2026';

@ApiExcludeController()
@Controller('test')
export class TestResetController {
  constructor(
    @InjectRepository(Todo) private readonly todos: Repository<Todo>,
  ) {}

  @Post('reset')
  @HttpCode(HttpStatus.NO_CONTENT)
  async reset(
    @Headers('x-e2e-reset-token') token: string | undefined,
  ): Promise<void> {
    if (token !== E2E_RESET_TOKEN) {
      throw new ForbiddenException();
    }
    await this.todos.clear();
  }
}
