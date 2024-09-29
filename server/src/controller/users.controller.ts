// users.controller.ts
import { Controller, Get, Post, Body, Param, Delete } from '@nestjs/common';
import { CreateUserDto } from '../dto/create-user.dto';
import { UsersService } from '../service/users.service';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  async create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  async findAll() {
    return this.usersService.findAll();
  }
  @Get('findbyname/:name')
  async findbyName(@Param('name') name: string) {
    return this.usersService.findByName(name);
  }

  @Get(':id')
  async getUserById(@Param('id') id: string) {
    return await this.usersService.findOne(id);
  }

  @Get('Find/:id')
  async getById(@Param('id') id: string) {
    return await this.usersService.findbyID(id);
  }

  @Get('findemail/:email')
  async getByEmail(@Param('email') email: string) {
    return await this.usersService.findbyemail(email);
  }

  @Delete(':id')
  async deleteUser(@Param('id') id: string) {
      return await this.usersService.deleteUser(id);
  }
}
