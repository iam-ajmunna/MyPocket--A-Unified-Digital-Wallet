import { Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { SyncService } from './sync.service';
import { RegisterDeviceDto } from './dto/register-device.dto';

@Controller('api/v1/sync')
@UseGuards(JwtAuthGuard)
export class SyncController {
  constructor(private readonly syncService: SyncService) {}

  @Post('device')
  async registerDevice(@Request() req: any, @Body() dto: RegisterDeviceDto) {
    return this.syncService.registerDevice(req.user.id, dto);
  }

  @Get('status')
  async getStatus(@Request() req: any) {
    return this.syncService.getSyncStatus(req.user.id);
  }
}
