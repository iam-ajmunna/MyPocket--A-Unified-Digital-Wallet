export interface MfsProviderDetails {
  providerName: string;
  accountNumber: string;
  accountName: string;
}

export interface IMfsProvider {
  getProviderName(): string;
  formatReceiveQrPayload(accountNumber: string, accountName: string): string;
}

export class BkashAdapter implements IMfsProvider {
  getProviderName(): string {
    return 'bKash';
  }
  formatReceiveQrPayload(accountNumber: string, accountName: string): string {
    return `bkash://pay?account=${accountNumber}&name=${encodeURIComponent(accountName)}`;
  }
}

export class NagadAdapter implements IMfsProvider {
  getProviderName(): string {
    return 'Nagad';
  }
  formatReceiveQrPayload(accountNumber: string, accountName: string): string {
    return `nagad://pay?account=${accountNumber}&name=${encodeURIComponent(accountName)}`;
  }
}

export class UpayAdapter implements IMfsProvider {
  getProviderName(): string {
    return 'Upay';
  }
  formatReceiveQrPayload(accountNumber: string, accountName: string): string {
    return `upay://pay?account=${accountNumber}&name=${encodeURIComponent(accountName)}`;
  }
}
