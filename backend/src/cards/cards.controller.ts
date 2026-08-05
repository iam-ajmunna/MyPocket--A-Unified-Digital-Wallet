import { Controller, Get, Post, Delete, Body, Param, UseGuards, Req } from '@nestjs/common';
import { CardsService } from './cards.service';
import { CreateCardDto } from './dto/create-card.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@Controller('api/v1/cards')
@UseGuards(JwtAuthGuard)
export class CardsController {
  constructor(private readonly cardsService: CardsService) {}

  @Get()
  async getCards(@Req() req: any) {
    return this.cardsService.getUserCards(req.user.id);
  }

  @Post()
  async createCard(@Req() req: any, @Body() dto: CreateCardDto) {
    return this.cardsService.createCard(req.user.id, dto);
  }

  @Post(':id/confirm')
  async confirmCard(@Req() req: any, @Param('id') id: string) {
    return this.cardsService.confirmCard(req.user.id, id);
  }

  @Delete(':id')
  async deleteCard(@Req() req: any, @Param('id') id: string) {
    return this.cardsService.deleteCard(req.user.id, id);
  }
}
