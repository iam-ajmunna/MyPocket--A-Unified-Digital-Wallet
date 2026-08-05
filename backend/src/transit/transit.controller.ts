import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { TransitService } from './transit.service';
import { CreateTransitPassDto, RechargeTransitPassDto } from './dto/create-transit-pass.dto';

@Controller('api/v1/transit')
@UseGuards(JwtAuthGuard)
export class TransitController {
  constructor(private readonly transitService: TransitService) {}

  @Get()
  async getTransitPasses(@Request() req: any) {
    return this.transitService.getTransitPasses(req.user.id);
  }

  @Post()
  async addTransitPass(@Request() req: any, @Body() dto: CreateTransitPassDto) {
    return this.transitService.addTransitPass(req.user.id, dto);
  }

  @Post(':id/recharge')
  async recharge(@Request() req: any, @Param('id') id: string, @Body() dto: RechargeTransitPassDto) {
    return this.transitService.recharge(req.user.id, id, dto);
  }

  @Post(':id/qr')
  async refreshQr(@Request() req: any, @Param('id') id: string) {
    return this.transitService.refreshQrToken(req.user.id, id);
  }

  @Delete(':id')
  async deleteTransitPass(@Request() req: any, @Param('id') id: string) {
    return this.transitService.deleteTransitPass(req.user.id, id);
  }
}
