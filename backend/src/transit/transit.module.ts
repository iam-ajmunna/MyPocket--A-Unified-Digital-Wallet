import { Module } from '@nestjs/common';
import { TransitController } from './transit.controller';
import { TransitService } from './transit.service';
import { PrismaModule } from '../prisma/prisma.module';
import { CryptoModule } from '../crypto/crypto.module';

@Module({
  imports: [PrismaModule, CryptoModule],
  controllers: [TransitController],
  providers: [TransitService],
  exports: [TransitService],
})
export class TransitModule {}
