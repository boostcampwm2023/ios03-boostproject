import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    rawBody: true,
  });
  const config = app.get(ConfigService);
  app.useBodyParser('json', { type: 'application/json' });
  app.useBodyParser('raw', { type: '*/*', limit: '10MB' });
  app.useLogger(
    config.get('application.log') || ['log', 'warn', 'error', 'fatal'],
  );

  const documentConfig = new DocumentBuilder()
    .setTitle('어디갈래 api docs')
    .setDescription('어디갈래 앱 Api 문서입니다.')
    .setVersion('0.1')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'Token',
      },
      'access-token',
    )
    .build();
  const document = SwaggerModule.createDocument(app, documentConfig);
  SwaggerModule.setup('api', app, document);

  await app.listen(config.get('application.port') || 3000);
}
bootstrap();
