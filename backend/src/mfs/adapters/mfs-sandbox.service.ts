import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

export interface SandboxTransactionResult {
  transactionId: string;
  provider: string;
  accountNumber: string;
  type: 'CASHOUT' | 'SEND_MONEY' | 'ADD_MONEY';
  amount: number;
  status: 'SUCCESS' | 'FAILED';
  timestamp: string;
  referenceToken: string;
}

@Injectable()
export class MfsSandboxService {
  constructor(private readonly prisma: PrismaService) {}

  /// Simulate live bKash / Nagad Cashout Sandbox Transaction
  async processCashout(userId: string, mfsId: string, amount: number): Promise<SandboxTransactionResult> {
    const mfs = await this.prisma.mfsAccount.findFirst({
      where: { id: mfsId, userId },
    });

    if (!mfs) {
      throw new NotFoundException('MFS account not found or access denied');
    }

    const txId = `TX_BK_${Date.now()}_${Math.floor(1000 + Math.random() * 9000)}`;

    return {
      transactionId: txId,
      provider: mfs.provider,
      accountNumber: mfs.accountNumber,
      type: 'CASHOUT',
      amount,
      status: 'SUCCESS',
      timestamp: new Date().toISOString(),
      referenceToken: `REF_SANDBOX_${txId}`,
    };
  }

  /// Simulate live Send Money Sandbox Transaction
  async processSendMoney(userId: string, mfsId: string, recipientNumber: string, amount: number): Promise<SandboxTransactionResult> {
    const mfs = await this.prisma.mfsAccount.findFirst({
      where: { id: mfsId, userId },
    });

    if (!mfs) {
      throw new NotFoundException('MFS account not found or access denied');
    }

    const txId = `TX_NG_${Date.now()}_${Math.floor(1000 + Math.random() * 9000)}`;

    return {
      transactionId: txId,
      provider: mfs.provider,
      accountNumber: recipientNumber,
      type: 'SEND_MONEY',
      amount,
      status: 'SUCCESS',
      timestamp: new Date().toISOString(),
      referenceToken: `REF_SANDBOX_${txId}`,
    };
  }
}
