import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CertificatesService } from './certificates.service';
import { CreateCertificateDto } from './dto/create-certificate.dto';

@Controller('api/v1/certificates')
@UseGuards(JwtAuthGuard)
export class CertificatesController {
  constructor(private readonly certificatesService: CertificatesService) {}

  @Get()
  async getCertificates(@Request() req: any) {
    return this.certificatesService.getCertificates(req.user.id);
  }

  @Post()
  async addCertificate(@Request() req: any, @Body() dto: CreateCertificateDto) {
    return this.certificatesService.addCertificate(req.user.id, dto);
  }

  @Delete(':id')
  async deleteCertificate(@Request() req: any, @Param('id') id: string) {
    return this.certificatesService.deleteCertificate(req.user.id, id);
  }
}
