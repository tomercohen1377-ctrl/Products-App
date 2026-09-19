import 'package:auth/src/domain/entities/auth_tokens.dart';
import 'package:auth/src/domain/entities/user.dart';

/// Sample data shared by previews and tests.
const userFixture = User(
  id: 1,
  email: 'john@mail.com',
  name: 'John',
  avatarUrl: 'https://i.imgur.com/LDOO4Qs.jpg',
);

const authTokensFixture = AuthTokens(
  accessToken: 'access-1',
  refreshToken: 'refresh-1',
);
