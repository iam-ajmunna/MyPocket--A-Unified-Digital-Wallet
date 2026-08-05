import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CryptoService } from '../crypto/crypto.service';
import { CreateCertificateDto } from './dto/create-certificate.dto';

@Injectable()
export class CertificatesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly cryptoService: CryptoService,
  ) {}

  private async getDek(userId: string): Promise<Buffer> {
    const userKey = await this.prisma.userKey.findUnique({ where: { userId } });
    if (!userKey) throw new BadRequestException('User encryption key missing');
    return this.cryptoService.unwrapDek(userKey.wrappedDek, userKey.iv, userKey.authTag);
  }

  async getCertificates(userId: string) {
    const certs = await this.prisma.certificate.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        name: true,
        issuer: true,
        issueDate: true,
        category: true,
        subCategory: true,
        createdAt: true,
      },
    });
    return certs;
  }

  async addCertificate(userId: string, dto: CreateCertificateDto) {
    const dek = await this.getDek(userId);
    const encrypted = this.cryptoService.encrypt(JSON.stringify(dto), dek);

    const cert = await this.prisma.certificate.create({
      data: {
        userId,
        name: dto.name,
        issuer: dto.issuer,
        issueDate: dto.issueDate,
        category: dto.category,
        subCategory: dto.subCategory ?? null,
        encryptedData: encrypted.ciphertext,
        iv: encrypted.iv,
        authTag: encrypted.authTag,
      },
    });

    return {
      id: cert.id,
      name: cert.name,
      issuer: cert.issuer,
      issueDate: cert.issueDate,
      category: cert.category,
      subCategory: cert.subCategory,
      createdAt: cert.createdAt,
    };
  }

  async deleteCertificate(userId: string, certificateId: string) {
    const cert = await this.prisma.certificate.findUnique({ where: { id: certificateId } });
    if (!cert || cert.userId !== userId) throw new NotFoundException('Certificate not found');
    await this.prisma.certificate.delete({ where: { id: certificateId } });
    return { success: true };
  }
}
