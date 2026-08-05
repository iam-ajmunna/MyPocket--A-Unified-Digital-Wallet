import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CryptoService } from '../crypto/crypto.service';
import { CreateCardDto } from './dto/create-card.dto';

@Injectable()
export class CardsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly cryptoService: CryptoService,
  ) {}

  async createCard(userId: string, dto: CreateCardDto) {
    const userKey = await this.prisma.userKey.findUnique({
      where: { userId },
    });

    if (!userKey) {
      throw new BadRequestException('User encryption key is missing');
    }

    const dek = this.cryptoService.unwrapDek(userKey.wrappedDek, userKey.iv, userKey.authTag);
    const plaintextData = JSON.stringify({
      cardholderName: dto.cardholderName,
      expiryDate: dto.expiryDate,
    });

    const encrypted = this.cryptoService.encrypt(plaintextData, dek);

    const card = await this.prisma.bankCard.create({
      data: {
        userId,
        bankName: dto.bankName,
        lastFourDigits: dto.lastFourDigits,
        encryptedCardData: encrypted.ciphertext,
        iv: encrypted.iv,
        authTag: encrypted.authTag,
      },
    });

    return {
      id: card.id,
      bankName: card.bankName,
      lastFourDigits: card.lastFourDigits,
      confirmedAt: card.confirmedAt,
      isImmutable: card.confirmedAt !== null,
    };
  }

  async confirmCard(userId: string, cardId: string) {
    const card = await this.prisma.bankCard.findFirst({
      where: { id: cardId, userId },
    });

    if (!card) {
      throw new NotFoundException('Card not found');
    }

    if (card.confirmedAt) {
      throw new BadRequestException('Card entry is already confirmed and immutable');
    }

    const updated = await this.prisma.bankCard.update({
      where: { id: cardId },
      data: { confirmedAt: new Date() },
    });

    return {
      id: updated.id,
      bankName: updated.bankName,
      lastFourDigits: updated.lastFourDigits,
      confirmedAt: updated.confirmedAt,
      isImmutable: true,
    };
  }

  async getUserCards(userId: string) {
    const cards = await this.prisma.bankCard.findMany({
      where: { userId },
      select: {
        id: true,
        bankName: true,
        lastFourDigits: true,
        confirmedAt: true,
        createdAt: true,
      },
    });

    return cards.map((c) => ({
      ...c,
      isImmutable: c.confirmedAt !== null,
    }));
  }

  async deleteCard(userId: string, cardId: string) {
    const card = await this.prisma.bankCard.findFirst({
      where: { id: cardId, userId },
    });

    if (!card) {
      throw new NotFoundException('Card not found');
    }

    await this.prisma.bankCard.delete({
      where: { id: cardId },
    });

    return { success: true };
  }
}
