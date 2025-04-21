import { APIGatewayProxyHandler } from 'aws-lambda';
import { CognitoIdentityServiceProvider } from 'aws-sdk';

const cognito = new CognitoIdentityServiceProvider();
const USER_POOL_ID = process.env.COGNITO_USER_POOL_ID;
const CLIENT_ID = process.env.COGNITO_CLIENT_ID;

export const auth: APIGatewayProxyHandler = async (event) => {
  try {
    switch (event.httpMethod) {
      case 'POST':
        if (event.path === '/api/auth/login') {
          const { username, password } = JSON.parse(event.body || '{}');
          
          const params = {
            AuthFlow: 'USER_PASSWORD_AUTH',
            ClientId: CLIENT_ID!,
            AuthParameters: {
              USERNAME: username,
              PASSWORD: password
            }
          };

          const authResult = await cognito.initiateAuth(params).promise();
          return {
            statusCode: 200,
            headers: {
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Credentials': true,
            },
            body: JSON.stringify({
              token: authResult.AuthenticationResult?.IdToken
            })
          };
        }
        break;

      case 'GET':
        if (event.path === '/api/auth/user') {
          const token = event.headers.Authorization?.split(' ')[1];
          const user = await cognito.getUser({
            AccessToken: token!
          }).promise();

          return {
            statusCode: 200,
            headers: {
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Credentials': true,
            },
            body: JSON.stringify({ user })
          };
        }
        break;
    }

    return {
      statusCode: 404,
      body: JSON.stringify({ message: 'Not Found' })
    };

  } catch (error) {
    console.error('Auth Error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal Server Error' })
    };
  }
}; 