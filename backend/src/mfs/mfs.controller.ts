import { Controller, Get, Post, Delete, Body, Param, UseGuards, Req } from '@nestjs/common';
import { MfsService } from './mfs.service';
import { CreateMfsDto } from './dto/create-mfs.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('api/v1/mfs')
@UseGuards(JwtAuthGuard)
export class MfsController {
  constructor(private readonly mfsService: MfsService) {}

  @Get()
  async getMfsAccounts(@Req() req: any) {
    return this.mfsService.getUserMfsAccounts(req.user.id);
  }

  @Post()
  async createMfs(@Req() req: any, @Body() dto: CreateMfsDto) {
    return this.mfsService.createMfs(req.user.id, dto);
  }

  @Post(':id/confirm')
  async confirmMfs(@Req() req: any, @Param('id') id: string) {
    return this.mfsService.confirmMfs(req.user.id, id);
  }

  @Delete(':id')
  async deleteMfs(@Req() req: any, @Param('id') id: string) {
    return this.mfsService.deleteMfs(req.user.id, id);
  }
}
