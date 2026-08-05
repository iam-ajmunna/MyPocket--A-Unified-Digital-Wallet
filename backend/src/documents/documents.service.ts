import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CryptoService } from '../crypto/crypto.service';
import { CreateNidDto } from './dto/create-nid.dto';
import { CreatePassportDto } from './dto/create-passport.dto';

@Injectable()
export class DocumentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly cryptoService: CryptoService,
  ) {}

  private async getDekForUser(userId: string): Promise<Buffer> {
    const userKey = await this.prisma.userKey.findUnique({
      where: { userId },
    });

    if (!userKey) {
      throw new BadRequestException('User encryption key is missing');
    }

    return this.cryptoService.unwrapDek(userKey.wrappedDek, userKey.iv, userKey.authTag);
  }

  async getUserDocuments(userId: string) {
    const documents = await this.prisma.document.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    return documents.map((doc) => ({
      id: doc.id,
      docType: doc.docType,
      docNumberMasked: doc.docNumberMasked,
      confirmedAt: doc.confirmedAt,
      createdAt: doc.createdAt,
    }));
  }

  async addNid(userId: string, dto: CreateNidDto) {
    const dek = await this.getDekForUser(userId);
    const maskedNumber = this.maskNumber(dto.nidNumber, 'NID');
    const encrypted = this.cryptoService.encrypt(JSON.stringify(dto), dek);

    const document = await this.prisma.document.create({
      data: {
        userId,
        docType: 'NID',
        docNumberMasked: maskedNumber,
        encryptedFields: encrypted.ciphertext,
        iv: encrypted.iv,
        authTag: encrypted.authTag,
        confirmedAt: new Date(),
      },
    });

    return {
      id: document.id,
      docType: document.docType,
      docNumberMasked: document.docNumberMasked,
      confirmedAt: document.confirmedAt,
      createdAt: document.createdAt,
    };
  }

  async addPassport(userId: string, dto: CreatePassportDto) {
    const dek = await this.getDekForUser(userId);
    const maskedNumber = this.maskNumber(dto.passportNumber, 'PASSPORT');
    const encrypted = this.cryptoService.encrypt(JSON.stringify(dto), dek);

    const document = await this.prisma.document.create({
      data: {
        userId,
        docType: 'PASSPORT',
        docNumberMasked: maskedNumber,
        encryptedFields: encrypted.ciphertext,
        iv: encrypted.iv,
        authTag: encrypted.authTag,
        confirmedAt: new Date(),
      },
    });

    return {
      id: document.id,
      docType: document.docType,
      docNumberMasked: document.docNumberMasked,
      confirmedAt: document.confirmedAt,
      createdAt: document.createdAt,
    };
  }

  async revealDocumentDetails(userId: string, documentId: string) {
    const doc = await this.prisma.document.findUnique({
      where: { id: documentId },
    });

    if (!doc) {
      throw new NotFoundException('Document not found');
    }

    if (doc.userId !== userId) {
      throw new ForbiddenException('Access denied');
    }

    const dek = await this.getDekForUser(userId);
    const decryptedJson = this.cryptoService.decrypt(doc.encryptedFields, doc.iv, doc.authTag, dek);
    const details = JSON.parse(decryptedJson);

    return {
      id: doc.id,
      docType: doc.docType,
      docNumberMasked: doc.docNumberMasked,
      confirmedAt: doc.confirmedAt,
      createdAt: doc.createdAt,
      details,
    };
  }

  async deleteDocument(userId: string, documentId: string) {
    const doc = await this.prisma.document.findUnique({
      where: { id: documentId },
    });

    if (!doc || doc.userId !== userId) {
      throw new NotFoundException('Document not found');
    }

    await this.prisma.document.delete({
      where: { id: documentId },
    });

    return { success: true };
  }

  private maskNumber(raw: string, type: string): string {
    if (!raw || raw.length < 4) return '••••';
    const last4 = raw.slice(-4);
    const first3 = raw.slice(0, 3);
    if (type === 'NID') {
      return `${first3}••••••••${last4}`;
    }
    return `${first3}••••${last4}`;
  }
}
