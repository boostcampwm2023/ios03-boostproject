import { Body, Controller, Delete, Post } from '@nestjs/common';
import { ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AppleClientAuthBody } from './apple.client.auth.body.dto';
import { AppleClientAuthResponse } from './apple.client.auth.response.dto';
import { AppleClientRefreshResponse } from './apple.client.refresh.response.dto';
import { AppleClientRefreshBody } from './apple.client.refresh.body.dto';
import { AppleAuthService } from './apple.auth.service';
import { Public } from '../auth.decorators';
import { plainToInstance } from 'class-transformer';

@Controller('apple')
export class AppleAuthController {
  constructor(private readonly appleAuthService: AppleAuthService) {}

  @ApiOperation({
    description:
      'Apple 로그인 혹은 회원가입을 실행하여 refresh token과 access token을 반환합니다.',
  })
  @ApiResponse({ type: AppleClientAuthResponse })
  @Public()
  @Post('auth')
  async auth(@Body() payload: AppleClientAuthBody) {
    return plainToInstance(
      AppleClientAuthResponse,
      await this.appleAuthService.auth(payload),
    );
  }

  @ApiOperation({
    description: 'Apple 회원탈퇴를 진행합니다. 미구현',
  })
  @ApiResponse({ type: AppleClientRefreshResponse })
  @Delete('revoke')
  async refresh(@Body() payload: AppleClientRefreshBody) {}
}
