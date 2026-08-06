import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReminderDto } from './dto/create-reminder.dto';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async getUserNotifications(userId: string) {
    const notifications = await this.prisma.notification.findMany({
      where: { userId, dismissedAt: null },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    const unreadCount = await this.prisma.notification.count({
      where: { userId, isRead: false, dismissedAt: null },
    });

    return { notifications, unreadCount };
  }

  async markAsRead(userId: string, notificationId: string) {
    const notif = await this.prisma.notification.findFirst({
      where: { id: notificationId, userId },
    });

    if (!notif) {
      throw new NotFoundException('Notification not found');
    }

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { isRead: true },
    });
  }

  async markAllAsRead(userId: string) {
    await this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });

    return { success: true };
  }

  async createReminder(userId: string, dto: CreateReminderDto) {
    return this.prisma.notification.create({
      data: {
        userId,
        title: dto.title,
        body: dto.body,
        type: dto.type,
        scheduledFor: dto.scheduledFor ? new Date(dto.scheduledFor) : null,
      },
    });
  }

  async dismissNotification(userId: string, notificationId: string) {
    const notif = await this.prisma.notification.findFirst({
      where: { id: notificationId, userId },
    });

    if (!notif) {
      throw new NotFoundException('Notification not found');
    }

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { dismissedAt: new Date() },
    });
  }

  // Automatic scanner helper (can be triggered by background job)
  async scanVaultForExpiriesAndAlerts(userId: string) {
    const createdAlerts = [];

    // Check Transit Passes for low balance (< 100 Tk)
    const lowBalancePasses = await this.prisma.transitPass.findMany({
      where: { userId, balance: { lt: 100 } },
    });

    for (const pass of lowBalancePasses) {
      const title = 'Low Transit Balance Warning 🚇';
      const body = `${pass.name} (${pass.transitType}) balance is low: Tk ${pass.balance}. Recharge soon!`;
      
      const existing = await this.prisma.notification.findFirst({
        where: { userId, title, isRead: false },
      });

      if (!existing) {
        const notif = await this.prisma.notification.create({
          data: {
            userId,
            title,
            body,
            type: 'EXPIRY_WARNING',
          },
        });
        createdAlerts.push(notif);
      }
    }

    return createdAlerts;
  }
}
