import { IsNotEmpty, IsString, Length } from 'class-validator';

export class CreatePassportDto {
  @IsNotEmpty()
  @IsString()
  @Length(7, 10, { message: 'Passport number must be between 7 and 10 alphanumeric characters' })
  passportNumber: string;

  @IsNotEmpty()
  @IsString()
  fullName: string;

  @IsNotEmpty()
  @IsString()
  countryCode: string;

  @IsNotEmpty()
  @IsString()
  dateOfBirth: string; // YYYY-MM-DD

  @IsNotEmpty()
  @IsString()
  expiryDate: string; // YYYY-MM-DD

  @IsNotEmpty()
  @IsString()
  issueDate: string; // YYYY-MM-DD
}
