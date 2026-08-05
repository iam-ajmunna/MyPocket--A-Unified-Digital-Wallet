import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { DocumentsService } from './documents.service';
import { CreateNidDto } from './dto/create-nid.dto';
import { CreatePassportDto } from './dto/create-passport.dto';

@Controller('api/v1/documents')
@UseGuards(JwtAuthGuard)
export class DocumentsController {
  constructor(private readonly documentsService: DocumentsService) {}

  @Get()
  async getDocuments(@Request() req: any) {
    return this.documentsService.getUserDocuments(req.user.id);
  }

  @Post('nid')
  async addNid(@Request() req: any, @Body() dto: CreateNidDto) {
    return this.documentsService.addNid(req.user.id, dto);
  }

  @Post('passport')
  async addPassport(@Request() req: any, @Body() dto: CreatePassportDto) {
    return this.documentsService.addPassport(req.user.id, dto);
  }

  @Post(':id/reveal')
  async revealDocument(@Request() req: any, @Param('id') id: string) {
    return this.documentsService.revealDocumentDetails(req.user.id, id);
  }

  @Delete(':id')
  async deleteDocument(@Request() req: any, @Param('id') id: string) {
    return this.documentsService.deleteDocument(req.user.id, id);
  }
}
