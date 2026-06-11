import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Todo } from '../todos/todo.entity';
import { TestResetController } from './test-reset.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Todo])],
  controllers: [TestResetController],
})
export class TestResetModule {}
