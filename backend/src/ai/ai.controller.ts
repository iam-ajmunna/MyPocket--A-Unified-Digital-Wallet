import { Controller, Post, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AiService } from './ai.service';
import { ChatMessageDto } from './dto/chat-message.dto';

@Controller('api/v1/ai')
@UseGuards(JwtAuthGuard)
export class AiController {
  constructor(private readonly aiService: AiService) {}

  @Post('chat')
  async chat(@Request() req: any, @Body() dto: ChatMessageDto) {
    const userId = req.user.id;
    return this.aiService.processMessage(userId, dto.message, dto.sessionId);
  }

  @Delete('session/:sessionId')
  async clearSession(@Param('sessionId') sessionId: string) {
    return this.aiService.clearSession(sessionId);
  }
}
