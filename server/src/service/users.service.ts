// users.service.ts
import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from '../schema/user.schema';
import { CreateUserDto } from 'src/dto/create-user.dto';

@Injectable()
export class UsersService {
  constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    const createdUser = new this.userModel(createUserDto);
    return createdUser.save();
  }

  async findAll(): Promise<User[]> {
    return this.userModel.find().exec();
  }

  async findByName(name: string): Promise<User[]> {
    return this.userModel.find({ name: new RegExp(name, 'i') }).exec();
  }

  async findOne(id: string): Promise<User> {
    console.log('Hey I found this guy: ', id);
    return await this.userModel.findOne({ _id: id }).exec();
  }
  async findbyemail(email: string): Promise<User> {
    console.log('Hey I found this guy: ', email);
    return await this.userModel.findOne({ email: email }).exec();
  }

  async findbyID(id: string): Promise<User> {
    console.log('vãi l : ', id);
    return this.userModel.findById(id);
  }
}
