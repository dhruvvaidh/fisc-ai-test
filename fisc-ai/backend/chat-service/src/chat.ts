import { APIGatewayProxyHandler } from 'aws-lambda';
import { LexRuntimeServiceClient } from '@aws-sdk/client-lex-runtime-service';

export const handler: APIGatewayProxyHandler = async (event) => {
  const lex = new LexRuntimeServiceClient({});
  const { message } = JSON.parse(event.body || '{}');

  try {
    const response = await lex.postText({
      botName: 'FiscAIBot',
      botAlias: 'prod',
      userId: event.requestContext.authorizer?.claims.sub,
      inputText: message
    });

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify(response)
    };
  } catch (error) {
    console.error('Lex error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Chat processing failed' })
    };
  }
}; 