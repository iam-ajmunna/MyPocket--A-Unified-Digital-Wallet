import { IsBoolean, IsEnum, IsNotEmpty, IsOptional, IsString, Matches } from 'class-validator';

export enum MfsProviderEnum {
  BKASH = 'bKash',
  NAGAD = 'Nagad',
  UPAY = 'Upay',
}

export class CreateMfsDto {
  @IsEnum(MfsProviderEnum, { message: 'Provider must be bKash, Nagad, or Upay' })
  provider: MfsProviderEnum;

  @IsString()
  @IsNotEmpty()
  @Matches(/^01[3-9]\d{8}$/, { message: 'Account number must be a valid 11-digit Bangladeshi mobile number' })
  accountNumber: string;

  @IsString()
  @IsNotEmpty({ message: 'Account holder name is required' })
  accountName: string;

  @IsBoolean()
  @IsOptional()
  smartSync?: boolean;
}
