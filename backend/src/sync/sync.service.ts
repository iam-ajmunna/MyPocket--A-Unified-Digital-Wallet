import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDeviceDto } from './dto/register-device.dto';

@Injectable()
export class SyncService {
  constructor(private readonly prisma: PrismaService) {}

  async registerDevice(userId: string, dto: RegisterDeviceDto) {
    return this.prisma.deviceToken.upsert({
      where: {
        userId_deviceToken: {
          userId,
          deviceToken: dto.deviceToken,
        },
      },
      update: {
        platform: dto.platform,
        lastSyncAt: new Date(),
      },
      create: {
        userId,
        deviceToken: dto.deviceToken,
        platform: dto.platform,
        lastSyncAt: new Date(),
      },
    });
  }

  async getSyncStatus(userId: string) {
    const devices = await this.prisma.deviceToken.findMany({
      where: { userId },
      select: { platform: true, lastSyncAt: true, createdAt: true },
    });

    return {
      serverTime: new Date().toISOString(),
      registeredDevicesCount: devices.length,
      devices,
    };
  }
}
