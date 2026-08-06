import { Controller, Get, Post, Delete, Body, Param, UseGuards, Req } from '@nestjs/common';
import { MfsService } from './mfs.service';
import { MfsSandboxService } from './adapters/mfs-sandbox.service';
import { CreateMfsDto } from './dto/create-mfs.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('api/v1/mfs')
@UseGuards(JwtAuthGuard)
export class MfsController {
  constructor(
    private readonly mfsService: MfsService,
    private readonly sandboxService: MfsSandboxService,
  ) {}

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

  @Post('sandbox/cashout')
  async processSandboxCashout(@Req() req: any, @Body() body: { mfsId: string; amount: number }) {
    return this.sandboxService.processCashout(req.user.id, body.mfsId, body.amount);
  }

  @Post('sandbox/sendmoney')
  async processSandboxSendMoney(@Req() req: any, @Body() body: { mfsId: string; recipientNumber: string; amount: number }) {
    return this.sandboxService.processSendMoney(req.user.id, body.mfsId, body.recipientNumber, body.amount);
  }
}
