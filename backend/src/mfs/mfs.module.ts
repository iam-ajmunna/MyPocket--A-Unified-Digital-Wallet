import { Module } from '@nestjs/common';
import { MfsService } from './mfs.service';
import { MfsController } from './mfs.controller';

@Module({
  controllers: [MfsController],
  providers: [MfsService],
  exports: [MfsService],
})
export class MfsModule {}
