import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenerativeAI, FunctionDeclaration, Content } from '@google/generative-ai';
import { PrismaService } from '../prisma/prisma.service';

interface ChatSession {
  history: Content[];
  lastUpdatedAt: Date;
}

@Injectable()
export class AiService {
  private readonly logger = new Logger(AiService.name);
  private genAI: GoogleGenerativeAI | null = null;
  private readonly sessions = new Map<string, ChatSession>();

  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    const apiKey = this.configService.get<string>('AI_API_KEY') || this.configService.get<string>('GEMINI_API_KEY');
    if (apiKey) {
      this.genAI = new GoogleGenerativeAI(apiKey);
    } else {
      this.logger.warn('AI_API_KEY not found in environment. Moon AI assistant will run in fallback smart mode.');
    }
  }

  // Define Function Declarations for Gemini Tool Calling
  private getFunctionDeclarations(): FunctionDeclaration[] {
    return [
      {
        name: 'get_wallet_summary',
        description: 'Get a summary of linked bank cards and MFS mobile wallet accounts for the authenticated user.',
        parameters: {
          type: 'OBJECT' as any,
          properties: {},
        },
      },
      {
        name: 'get_certificates',
        description: 'List academic, skills, business, and competition certificates stored in the user vault.',
        parameters: {
          type: 'OBJECT' as any,
          properties: {},
        },
      },
      {
        name: 'get_transit_passes',
        description: 'List transit passes (metro, bus, train) and their current balance in BDT (Tk).',
        parameters: {
          type: 'OBJECT' as any,
          properties: {},
        },
      },
      {
        name: 'get_documents_summary',
        description: 'Get summary of stored identity documents (NID, Passport, Driver License). Never reveals raw ID numbers.',
        parameters: {
          type: 'OBJECT' as any,
          properties: {},
        },
      },
    ];
  }

  async processMessage(userId: string, message: string, sessionId?: string): Promise<{ reply: string; sessionId: string }> {
    const sid = sessionId || `session_${userId}_${Date.now()}`;
    this.cleanExpiredSessions();

    let session = this.sessions.get(sid);
    if (!session) {
      session = { history: [], lastUpdatedAt: new Date() };
      this.sessions.set(sid, session);
    }
    session.lastUpdatedAt = new Date();

    const apiKey = this.configService.get<string>('AI_API_KEY') || this.configService.get<string>('GEMINI_API_KEY');

    if (!apiKey || !this.genAI) {
      // Offline / Fallback mode if API key not provided yet
      const fallbackReply = await this.handleFallbackMessage(userId, message);
      session.history.push({ role: 'user', parts: [{ text: message }] });
      session.history.push({ role: 'model', parts: [{ text: fallbackReply }] });
      return { reply: fallbackReply, sessionId: sid };
    }

    try {
      const model = this.genAI.getGenerativeModel({
        model: 'gemini-2.0-flash',
        systemInstruction: `You are "Moon", the official AI companion inside MyPocket digital wallet app.
Your role is to assist the user with their wallet overview, stored certificates, transit passes, and document vault in a warm, helpful, and concise tone.
Always preserve user security:
- NEVER ask for or output raw NID numbers, CVVs, full card numbers, or passwords.
- Answer in the user's language (Bangla, English, or Banglish).
- Use tools whenever asked about balances, cards, transit, certificates, or documents.`,
        tools: [{ functionDeclarations: this.getFunctionDeclarations() }],
      });

      const chat = model.startChat({
        history: session.history,
      });

      let response = await chat.sendMessage(message);
      let functionCalls = response.response.functionCalls();

      // Loop over function calls (tool calling)
      while (functionCalls && functionCalls.length > 0) {
        for (const call of functionCalls) {
          const toolResult = await this.executeTool(userId, call.name, call.args);
          response = await chat.sendMessage([
            {
              functionResponse: {
                name: call.name,
                response: toolResult,
              },
            },
          ]);
        }
        functionCalls = response.response.functionCalls();
      }

      const replyText = response.response.text() || "I'm here to help with your MyPocket wallet!";

      // Update session history from chat
      session.history = await chat.getHistory();

      return { reply: replyText, sessionId: sid };
    } catch (err: any) {
      this.logger.error(`Gemini AI execution error: ${err.message}`, err.stack);
      // Fall back gracefully if Gemini API throws rate limit or error
      const fallbackReply = await this.handleFallbackMessage(userId, message);
      session.history.push({ role: 'user', parts: [{ text: message }] });
      session.history.push({ role: 'model', parts: [{ text: fallbackReply }] });
      return { reply: fallbackReply, sessionId: sid };
    }
  }

  private async executeTool(userId: string, name: string, _args: any): Promise<any> {
    switch (name) {
      case 'get_wallet_summary': {
        const cards = await this.prisma.bankCard.findMany({
          where: { userId },
          select: { bankName: true, lastFourDigits: true },
        });
        const mfs = await this.prisma.mfsAccount.findMany({
          where: { userId },
          select: { provider: true, accountName: true, accountNumber: true },
        });
        return {
          cards: cards.map(c => ({ bank: c.bankName, cardEnding: c.lastFourDigits })),
          mfsWallets: mfs.map(m => ({
            provider: m.provider,
            name: m.accountName,
            numberEnding: m.accountNumber.slice(-4),
          })),
        };
      }
      case 'get_certificates': {
        const certs = await this.prisma.certificate.findMany({
          where: { userId },
          select: { name: true, issuer: true, category: true, subCategory: true, issueDate: true },
        });
        return {
          totalCertificates: certs.length,
          certificates: certs.map(c => ({
            title: c.name,
            issuer: c.issuer,
            category: c.category,
            subCategory: c.subCategory,
            issueDate: c.issueDate,
          })),
        };
      }
      case 'get_transit_passes': {
        const passes = await this.prisma.transitPass.findMany({
          where: { userId },
          select: { name: true, transitType: true, lastFourDigits: true, balance: true, expiryDate: true },
        });
        return {
          totalPasses: passes.length,
          passes: passes.map(p => ({
            name: p.name,
            type: p.transitType,
            cardEnding: p.lastFourDigits,
            balanceBdt: p.balance,
            expiryDate: p.expiryDate,
          })),
        };
      }
      case 'get_documents_summary': {
        const docs = await this.prisma.document.findMany({
          where: { userId },
          select: { docType: true, docNumberMasked: true },
        });
        return {
          totalDocuments: docs.length,
          documents: docs.map(d => ({
            type: d.docType,
            maskedNumber: d.docNumberMasked,
          })),
        };
      }
      default:
        return { error: 'Unknown tool' };
    }
  }

  private async handleFallbackMessage(userId: string, text: string): Promise<string> {
    const lower = text.toLowerCase();
    if (lower.includes('card') || lower.includes('wallet') || lower.includes('mfs') || lower.includes('bank')) {
      const summary = await this.executeTool(userId, 'get_wallet_summary', {});
      if (summary.cards.length === 0 && summary.mfsWallets.length === 0) {
        return "You don't have any linked cards or MFS wallets in your MyPocket wallet yet. Tap 'Cards & MFS' on your dashboard to add one!";
      }
      const cardStr = summary.cards.map((c: any) => `${c.bank} (ending ${c.cardEnding})`).join(', ');
      const mfsStr = summary.mfsWallets.map((m: any) => `${m.provider} (${m.name})`).join(', ');
      return `Here is your wallet overview 💳:\n- Bank Cards: ${cardStr || 'None'}\n- Mobile Wallets: ${mfsStr || 'None'}`;
    }

    if (lower.includes('transit') || lower.includes('metro') || lower.includes('bus') || lower.includes('balance')) {
      const passes = await this.executeTool(userId, 'get_transit_passes', {});
      if (passes.totalPasses === 0) {
        return "You don't have any transit passes in your vault yet. Add your MRT Pass or Rapid Pass from the Transit screen!";
      }
      const passStr = passes.passes.map((p: any) => `• ${p.name} (${p.type}): Tk ${p.balanceBdt}`).join('\n');
      return `Here are your Transit Passes 🚇:\n${passStr}`;
    }

    if (lower.includes('cert') || lower.includes('academic') || lower.includes('degree') || lower.includes('skill')) {
      const certs = await this.executeTool(userId, 'get_certificates', {});
      if (certs.totalCertificates === 0) {
        return "No certificates found in your digital vault. Upload your academic or skill credentials from the Certificates screen!";
      }
      const certStr = certs.certificates.map((c: any) => `• ${c.title} by ${c.issuer} (${c.category})`).join('\n');
      return `You have ${certs.totalCertificates} stored certificate(s) 🎓:\n${certStr}`;
    }

    if (lower.includes('nid') || lower.includes('passport') || lower.includes('doc') || lower.includes('id')) {
      const docs = await this.executeTool(userId, 'get_documents_summary', {});
      if (docs.totalDocuments === 0) {
        return "You haven't added any identity documents to your secure vault yet. Head to the Documents screen to store your NID or Passport!";
      }
      const items = docs.documents.map((d: any) => `• ${d.type} (${d.maskedNumber})`).join('\n');
      return `Stored Identity Documents 🛡️:\n${items}`;
    }

    return `Hello! I'm Moon, your MyPocket AI Assistant 🌙. I can help you check your stored cards, transit pass balances, certificates, or document vault status. What would you like to check today?`;
  }

  clearSession(sessionId: string) {
    this.sessions.delete(sessionId);
    return { success: true, message: 'Session cleared' };
  }

  private cleanExpiredSessions() {
    const now = Date.now();
    const ttlMs = 30 * 60 * 1000; // 30 mins
    for (const [sid, session] of this.sessions.entries()) {
      if (now - session.lastUpdatedAt.getTime() > ttlMs) {
        this.sessions.delete(sid);
      }
    }
  }
}
