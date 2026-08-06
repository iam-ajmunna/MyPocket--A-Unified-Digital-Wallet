import { Module } from '@nestjs/common';
import { MfsService } from './mfs.service';
import { MfsController } from './mfs.controller';
import { MfsSandboxService } from './adapters/mfs-sandbox.service';

@Module({
  controllers: [MfsController],
  providers: [MfsService, MfsSandboxService],
  exports: [MfsService, MfsSandboxService],
})
export class MfsModule {}
