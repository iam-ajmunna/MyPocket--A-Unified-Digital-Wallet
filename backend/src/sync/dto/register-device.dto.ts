import { IsString, IsNotEmpty, IsIn } from 'class-validator';

export class RegisterDeviceDto {
  @IsString()
  @IsNotEmpty()
  deviceToken: string;

  @IsString()
  @IsIn(['ANDROID', 'IOS', 'WEB'])
  platform: string;
}
