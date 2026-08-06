import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { CryptoService } from './crypto.service';

describe('CryptoService Audit Pass', () => {
  let service: CryptoService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CryptoService,
        {
          provide: ConfigService,
          useValue: {
            get: (key: string) => {
              if (key === 'MASTER_KEY_HEX') {
                return '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
              }
              return null;
            },
          },
        },
      ],
    }).compile();

    service = module.get<CryptoService>(CryptoService);
  });

  it('should generate a 32-byte (256-bit) DEK', () => {
    const dek = service.generateDek();
    expect(dek).toBeInstanceOf(Buffer);
    expect(dek.length).toBe(32);
  });

  it('should wrap and unwrap DEK correctly with KEK', () => {
    const originalDek = service.generateDek();
    const wrapped = service.wrapDek(originalDek);

    expect(wrapped.wrappedDek).toBeDefined();
    expect(wrapped.iv).toBeDefined();
    expect(wrapped.authTag).toBeDefined();

    const unwrappedDek = service.unwrapDek(wrapped.wrappedDek, wrapped.iv, wrapped.authTag);
    expect(unwrappedDek).toEqual(originalDek);
  });

  it('should encrypt and decrypt NID/card sensitive data using DEK with AES-256-GCM', () => {
    const dek = service.generateDek();
    const sensitiveJson = JSON.stringify({
      nidNumber: '19951234567890123',
      nameEn: 'Rahim Uddin',
      dateOfBirth: '1995-05-12',
    });

    const encrypted = service.encrypt(sensitiveJson, dek);
    expect(encrypted.ciphertext).not.toContain('19951234567890123');
    expect(encrypted.ciphertext).not.toContain('Rahim Uddin');

    const decrypted = service.decrypt(encrypted.ciphertext, encrypted.iv, encrypted.authTag, dek);
    expect(decrypted).toBe(sensitiveJson);
  });

  it('should fail decryption if authTag is tampered with', () => {
    const dek = service.generateDek();
    const sensitiveJson = 'SuperSecretData';
    const encrypted = service.encrypt(sensitiveJson, dek);

    // Tamper with authTag
    const tamperedTag = 'f' + encrypted.authTag.substring(1);

    expect(() => {
      service.decrypt(encrypted.ciphertext, encrypted.iv, tamperedTag, dek);
    }).toThrow();
  });
});
