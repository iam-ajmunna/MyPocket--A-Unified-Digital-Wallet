import { IsString, IsNotEmpty, IsOptional, IsDateString, IsIn } from 'class-validator';

export class CreateReminderDto {
  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  body: string;

  @IsString()
  @IsIn(['EXPIRY_WARNING', 'DUE_PAYMENT', 'SMART_SYNC', 'ANNOUNCEMENT', 'CUSTOM'])
  type: string;

  @IsDateString()
  @IsOptional()
  scheduledFor?: string;
}
