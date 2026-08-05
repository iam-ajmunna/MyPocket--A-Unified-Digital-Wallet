import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CryptoService } from '../crypto/crypto.service';
import { CreateTransitPassDto, RechargeTransitPassDto } from './dto/create-transit-pass.dto';
import { randomUUID } from 'crypto';

@Injectable()
export class TransitService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly cryptoService: CryptoService,
  ) {}

  private async getDek(userId: string): Promise<Buffer> {
    const userKey = await this.prisma.userKey.findUnique({ where: { userId } });
    if (!userKey) throw new BadRequestException('User encryption key missing');
    return this.cryptoService.unwrapDek(userKey.wrappedDek, userKey.iv, userKey.authTag);
  }

  async getTransitPasses(userId: string) {
    const passes = await this.prisma.transitPass.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        name: true,
        lastFourDigits: true,
        transitType: true,
        expiryDate: true,
        balance: true,
        qrToken: true,
        createdAt: true,
      },
    });
    return passes;
  }

  async addTransitPass(userId: string, dto: CreateTransitPassDto) {
    const dek = await this.getDek(userId);
    const lastFour = dto.cardNumber.slice(-4);
    const encrypted = this.cryptoService.encrypt(
      JSON.stringify({ cardNumber: dto.cardNumber }),
      dek,
    );
    const qrToken = randomUUID();

    const pass = await this.prisma.transitPass.create({
      data: {
        userId,
        name: dto.name,
        lastFourDigits: lastFour,
        transitType: dto.transitType,
        expiryDate: dto.expiryDate,
        balance: 0,
        qrToken,
        encryptedData: encrypted.ciphertext,
        iv: encrypted.iv,
        authTag: encrypted.authTag,
      },
    });

    return {
      id: pass.id,
      name: pass.name,
      lastFourDigits: pass.lastFourDigits,
      transitType: pass.transitType,
      expiryDate: pass.expiryDate,
      balance: pass.balance,
      qrToken: pass.qrToken,
      createdAt: pass.createdAt,
    };
  }

  async recharge(userId: string, passId: string, dto: RechargeTransitPassDto) {
    const pass = await this.prisma.transitPass.findUnique({ where: { id: passId } });
    if (!pass || pass.userId !== userId) throw new NotFoundException('Transit pass not found');
    if (dto.amount <= 0) throw new BadRequestException('Recharge amount must be positive');

    const updated = await this.prisma.transitPass.update({
      where: { id: passId },
      data: { balance: { increment: dto.amount } },
    });

    return {
      id: updated.id,
      name: updated.name,
      balance: updated.balance,
      transitType: updated.transitType,
    };
  }

  async refreshQrToken(userId: string, passId: string) {
    const pass = await this.prisma.transitPass.findUnique({ where: { id: passId } });
    if (!pass || pass.userId !== userId) throw new NotFoundException('Transit pass not found');

    const newToken = randomUUID();
    await this.prisma.transitPass.update({
      where: { id: passId },
      data: { qrToken: newToken },
    });

    return { qrToken: newToken };
  }

  async deleteTransitPass(userId: string, passId: string) {
    const pass = await this.prisma.transitPass.findUnique({ where: { id: passId } });
    if (!pass || pass.userId !== userId) throw new NotFoundException('Transit pass not found');
    await this.prisma.transitPass.delete({ where: { id: passId } });
    return { success: true };
  }
}
