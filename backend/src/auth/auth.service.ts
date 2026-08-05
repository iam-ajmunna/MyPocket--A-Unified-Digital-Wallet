import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as argon2 from 'argon2';
import * as crypto from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { CryptoService } from '../crypto/crypto.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly cryptoService: CryptoService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * Registers a new user with hashed password & envelope encryption keys.
   */
  async register(dto: RegisterDto) {
    // Check if user already exists with email or phone
    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: dto.email }, { phone: dto.phone }],
      },
    });

    if (existingUser) {
      if (existingUser.email === dto.email) {
        throw new ConflictException('User with this email already exists');
      }
      throw new ConflictException('User with this phone number already exists');
    }

    // Hash password with Argon2id
    const passwordHash = await argon2.hash(dto.password, {
      type: argon2.argon2id,
      memoryCost: 65536,
      timeCost: 3,
    });

    // Generate DEK and wrap with KEK for Envelope Encryption
    const rawDek = this.cryptoService.generateDek();
    const wrappedDek = this.cryptoService.wrapDek(rawDek);

    // Transaction to create User and UserKey atomically
    const user = await this.prisma.$transaction(async (tx) => {
      const createdUser = await tx.user.create({
        data: {
          email: dto.email,
          phone: dto.phone,
          passwordHash: passwordHash,
          fullName: dto.fullName,
        },
      });

      await tx.userKey.create({
        data: {
          userId: createdUser.id,
          wrappedDek: wrappedDek.wrappedDek,
          iv: wrappedDek.iv,
          authTag: wrappedDek.authTag,
        },
      });

      return createdUser;
    });

    const tokens = await this.generateTokens(user.id, user.email, user.phone);
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return {
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        fullName: user.fullName,
        createdAt: user.createdAt,
      },
      tokens,
    };
  }

  /**
   * Performs hybrid login accepting email or phone as identifier.
   */
  async login(dto: LoginDto) {
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: dto.identifier }, { phone: dto.identifier }],
      },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid email/phone or password');
    }

    const passwordValid = await argon2.verify(user.passwordHash, dto.password);
    if (!passwordValid) {
      throw new UnauthorizedException('Invalid email/phone or password');
    }

    const tokens = await this.generateTokens(user.id, user.email, user.phone);
    await this.storeRefreshToken(user.id, tokens.refreshToken);

    return {
      user: {
        id: user.id,
        email: user.email,
        phone: user.phone,
        fullName: user.fullName,
        createdAt: user.createdAt,
      },
      tokens,
    };
  }

  /**
   * Rotates refresh token and issues a new access/refresh pair.
   */
  async refreshTokens(dto: RefreshTokenDto) {
    try {
      const payload = this.jwtService.verify(dto.refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      const tokenHash = this.hashToken(dto.refreshToken);
      const existingToken = await this.prisma.refreshToken.findFirst({
        where: {
          userId: payload.sub,
          tokenHash: tokenHash,
          isRevoked: false,
        },
      });

      if (!existingToken || existingToken.expiresAt < new Date()) {
        throw new UnauthorizedException('Invalid or expired refresh token');
      }

      // Revoke old token
      await this.prisma.refreshToken.update({
        where: { id: existingToken.id },
        data: { isRevoked: true },
      });

      // Get user details and issue new pair
      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
      });

      if (!user) {
        throw new UnauthorizedException('User no longer exists');
      }

      const newTokens = await this.generateTokens(user.id, user.email, user.phone);
      await this.storeRefreshToken(user.id, newTokens.refreshToken);

      return newTokens;
    } catch (error) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }
  }

  /**
   * Revokes all active refresh tokens for the user upon logout.
   */
  async logout(userId: string) {
    await this.prisma.refreshToken.updateMany({
      where: { userId, isRevoked: false },
      data: { isRevoked: true },
    });
    return { success: true };
  }

  private async generateTokens(userId: string, email: string, phone: string): Promise<AuthTokens> {
    const payload = { sub: userId, email, phone };
    const accessSecret = this.configService.get<string>('JWT_ACCESS_SECRET');
    const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET');

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: accessSecret,
        expiresIn: '15m',
      }),
      this.jwtService.signAsync(payload, {
        secret: refreshSecret,
        expiresIn: '7d',
      }),
    ]);

    return { accessToken, refreshToken };
  }

  private async storeRefreshToken(userId: string, refreshToken: string) {
    const tokenHash = this.hashToken(refreshToken);
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    await this.prisma.refreshToken.create({
      data: {
        userId,
        tokenHash,
        expiresAt,
      },
    });
  }

  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }
}
