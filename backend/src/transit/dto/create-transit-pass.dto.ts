import { IsNotEmpty, IsString, IsIn, IsNumberString, Length } from 'class-validator';

export class CreateTransitPassDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @IsNumberString()
  @Length(8, 20)
  cardNumber: string;

  @IsNotEmpty()
  @IsIn(['Metro', 'Bus', 'Train', 'Ferry', 'Tram', 'Subway', 'Light Rail', 'Bike Share'])
  transitType: string;

  @IsNotEmpty()
  @IsString()
  expiryDate: string; // YYYY-MM-DD
}

export class RechargeTransitPassDto {
  @IsNotEmpty()
  amount: number;
}
