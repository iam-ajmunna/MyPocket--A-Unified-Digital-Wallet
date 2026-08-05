import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';

export interface EncryptedResult {
  ciphertext: string; // Hex string
  iv: string;         // Hex string
  authTag: string;    // Hex string
}

export interface WrappedKeyResult {
  wrappedDek: string; // Hex string
  iv: string;         // Hex string
  authTag: string;    // Hex string
}

@Injectable()
export class CryptoService {
  private readonly kek: Buffer;
  private readonly algorithm = 'aes-256-gcm';

  constructor(private readonly configService: ConfigService) {
    const kekHex = this.configService.get<string>('MASTER_KEY_HEX') || '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    if (kekHex.length !== 64) {
      throw new Error('MASTER_KEY_HEX must be a 64-character hex string (32 bytes)');
    }
    this.kek = Buffer.from(kekHex, 'hex');
  }

  /**
   * Generates a new 256-bit Data Encryption Key (DEK).
   */
  generateDek(): Buffer {
    return crypto.randomBytes(32);
  }

  /**
   * Wraps (encrypts) a user's DEK with the server-held KEK using AES-256-GCM.
   */
  wrapDek(dek: Buffer): WrappedKeyResult {
    try {
      const iv = crypto.randomBytes(12);
      const cipher = crypto.createCipheriv(this.algorithm, this.kek, iv);
      const encrypted = Buffer.concat([cipher.update(dek), cipher.final()]);
      const authTag = cipher.getAuthTag();

      return {
        wrappedDek: encrypted.toString('hex'),
        iv: iv.toString('hex'),
        authTag: authTag.toString('hex'),
      };
    } catch (error) {
      throw new InternalServerErrorException('Failed to wrap Data Encryption Key');
    }
  }

  /**
   * Unwraps (decrypts) a user's DEK using the server-held KEK.
   */
  unwrapDek(wrappedDekHex: string, ivHex: string, authTagHex: string): Buffer {
    try {
      const decipher = crypto.createDecipheriv(
        this.algorithm,
        this.kek,
        Buffer.from(ivHex, 'hex'),
      );
      decipher.setAuthTag(Buffer.from(authTagHex, 'hex'));

      const decrypted = Buffer.concat([
        decipher.update(Buffer.from(wrappedDekHex, 'hex')),
        decipher.final(),
      ]);

      return decrypted;
    } catch (error) {
      throw new InternalServerErrorException('Failed to unwrap Data Encryption Key');
    }
  }

  /**
   * Encrypts plaintext data using the user's unwrapped DEK (AES-256-GCM).
   */
  encrypt(plaintext: string, dek: Buffer): EncryptedResult {
    try {
      const iv = crypto.randomBytes(12);
      const cipher = crypto.createCipheriv(this.algorithm, dek, iv);
      const encrypted = Buffer.concat([
        cipher.update(plaintext, 'utf8'),
        cipher.final(),
      ]);
      const authTag = cipher.getAuthTag();

      return {
        ciphertext: encrypted.toString('hex'),
        iv: iv.toString('hex'),
        authTag: authTag.toString('hex'),
      };
    } catch (error) {
      throw new InternalServerErrorException('Data encryption failed');
    }
  }

  /**
   * Decrypts ciphertext back to plaintext using the user's unwrapped DEK.
   */
  decrypt(ciphertextHex: string, ivHex: string, authTagHex: string, dek: Buffer): string {
    try {
      const decipher = crypto.createDecipheriv(
        this.algorithm,
        dek,
        Buffer.from(ivHex, 'hex'),
      );
      decipher.setAuthTag(Buffer.from(authTagHex, 'hex'));

      const decrypted = Buffer.concat([
        decipher.update(Buffer.from(ciphertextHex, 'hex')),
        decipher.final(),
      ]);

      return decrypted.toString('utf8');
    } catch (error) {
      throw new InternalServerErrorException('Data decryption failed');
    }
  }
}
