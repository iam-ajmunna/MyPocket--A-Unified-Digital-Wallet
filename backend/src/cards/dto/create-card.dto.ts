import { IsNotEmpty, IsString, Length, Matches } from 'class-validator';

export class CreateCardDto {
  @IsString()
  @IsNotEmpty({ message: 'Bank name is required' })
  bankName: string;

  @IsString()
  @Length(4, 4, { message: 'Last 4 digits must be exactly 4 numbers' })
  @Matches(/^\d{4}$/, { message: 'Last 4 digits must be numeric' })
  lastFourDigits: string;

  @IsString()
  @IsNotEmpty({ message: 'Expiry date is required' })
  expiryDate: string; // MM/YY

  @IsString()
  @IsNotEmpty({ message: 'Cardholder name is required' })
  cardholderName: string;
}
