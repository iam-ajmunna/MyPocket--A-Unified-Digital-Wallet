import { Controller, Get, Post, Patch, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { NotificationsService } from './notifications.service';
import { CreateReminderDto } from './dto/create-reminder.dto';

@Controller('api/v1/notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  async getNotifications(@Request() req: any) {
    return this.notificationsService.getUserNotifications(req.user.id);
  }

  @Patch(':id/read')
  async markAsRead(@Request() req: any, @Param('id') id: string) {
    return this.notificationsService.markAsRead(req.user.id, id);
  }

  @Post('read-all')
  async markAllAsRead(@Request() req: any) {
    return this.notificationsService.markAllAsRead(req.user.id);
  }

  @Post('reminder')
  async createReminder(@Request() req: any, @Body() dto: CreateReminderDto) {
    return this.notificationsService.createReminder(req.user.id, dto);
  }

  @Delete(':id')
  async dismiss(@Request() req: any, @Param('id') id: string) {
    return this.notificationsService.dismissNotification(req.user.id, id);
  }

  @Post('scan')
  async scanVault(@Request() req: any) {
    return this.notificationsService.scanVaultForExpiriesAndAlerts(req.user.id);
  }
}
