import { IsNotEmpty, IsString, IsOptional, IsIn } from 'class-validator';

export class CreateCertificateDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @IsString()
  issuer: string;

  @IsNotEmpty()
  @IsString()
  issueDate: string; // YYYY-MM-DD

  @IsNotEmpty()
  @IsIn(['ACADEMIC', 'OLYMPIAD', 'QUIZCOMP', 'BIZCOMP', 'SPORTS', 'SKILLS'])
  category: string;

  @IsOptional()
  @IsIn(['SSC', 'HSC', 'UNDERGRAD', 'GRAD', 'PHD', 'POSTDOC', ''])
  subCategory?: string;
}
