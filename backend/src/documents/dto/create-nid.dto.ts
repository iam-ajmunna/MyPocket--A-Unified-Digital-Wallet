import { IsNotEmpty, IsString, Length, Matches } from 'class-validator';

export class CreateNidDto {
  @IsNotEmpty()
  @IsString()
  @Length(10, 17, { message: 'NID number must be between 10 and 17 digits' })
  nidNumber: string;

  @IsNotEmpty()
  @IsString()
  fullName: string;

  @IsNotEmpty()
  @IsString()
  dateOfBirth: string; // YYYY-MM-DD

  @IsNotEmpty()
  @IsString()
  fatherName: string;

  @IsNotEmpty()
  @IsString()
  motherName: string;

  @IsNotEmpty()
  @IsString()
  address: string;
}
