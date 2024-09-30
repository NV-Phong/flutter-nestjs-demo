// create-user.dto.ts
import { IsString, IsEmail } from 'class-validator';

export class UpdateUserDto {
  @IsString()
  name: string;

  @IsEmail()
  email: string;
}
