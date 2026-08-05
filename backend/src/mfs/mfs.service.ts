import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMfsDto, MfsProviderEnum } from './dto/create-mfs.dto';
import { BkashAdapter, NagadAdapter, UpayAdapter, IMfsProvider } from './adapters/mfs-provider.interface';

@Injectable()
export class MfsService {
  private readonly adapters: Record<string, IMfsProvider>;

  constructor(private readonly prisma: PrismaService) {
    this.adapters = {
      [MfsProviderEnum.BKASH]: new BkashAdapter(),
      [MfsProviderEnum.NAGAD]: new NagadAdapter(),
      [MfsProviderEnum.UPAY]: new UpayAdapter(),
    };
  }

  async createMfs(userId: string, dto: CreateMfsDto) {
    const adapter = this.adapters[dto.provider];
    if (!adapter) {
      throw new BadRequestException('Unsupported MFS provider');
    }

    const qrToken = adapter.formatReceiveQrPayload(dto.accountNumber, dto.accountName);

    const mfs = await this.prisma.mfsAccount.create({
      data: {
        userId,
        provider: dto.provider,
        accountNumber: dto.accountNumber,
        accountName: dto.accountName,
        qrCodeToken: qrToken,
        smartSync: dto.smartSync ?? false,
      },
    });

    return {
      id: mfs.id,
      provider: mfs.provider,
      accountNumber: mfs.accountNumber,
      accountName: mfs.accountName,
      qrCodeToken: mfs.qrCodeToken,
      smartSync: mfs.smartSync,
      confirmedAt: mfs.confirmedAt,
      isImmutable: mfs.confirmedAt !== null,
    };
  }

  async confirmMfs(userId: string, mfsId: string) {
    const mfs = await this.prisma.mfsAccount.findFirst({
      where: { id: mfsId, userId },
    });

    if (!mfs) {
      throw new NotFoundException('MFS account entry not found');
    }

    if (mfs.confirmedAt) {
      throw new BadRequestException('MFS entry is already confirmed and immutable');
    }

    const updated = await this.prisma.mfsAccount.update({
      where: { id: mfsId },
      data: { confirmedAt: new Date() },
    });

    return {
      id: updated.id,
      provider: updated.provider,
      accountNumber: updated.accountNumber,
      accountName: updated.accountName,
      smartSync: updated.smartSync,
      confirmedAt: updated.confirmedAt,
      isImmutable: true,
    };
  }

  async getUserMfsAccounts(userId: string) {
    const accounts = await this.prisma.mfsAccount.findMany({
      where: { userId },
      select: {
        id: true,
        provider: true,
        accountNumber: true,
        accountName: true,
        qrCodeToken: true,
        smartSync: true,
        confirmedAt: true,
        createdAt: true,
      },
    });

    return accounts.map((acc) => ({
      ...acc,
      isImmutable: acc.confirmedAt !== null,
    }));
  }

  async deleteMfs(userId: string, mfsId: string) {
    const mfs = await this.prisma.mfsAccount.findFirst({
      where: { id: mfsId, userId },
    });

    if (!mfs) {
      throw new NotFoundException('MFS account entry not found');
    }

    await this.prisma.mfsAccount.delete({
      where: { id: mfsId },
    });

    return { success: true };
  }
}
