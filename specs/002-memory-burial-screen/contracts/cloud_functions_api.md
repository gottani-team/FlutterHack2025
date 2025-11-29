# Cloud Functions API: Memory Burial

**作成日**: 2025-11-29  
**機能**: Memory Burial Screen  
**ブランチ**: `002-memory-burial-screen`

## 概要

このドキュメントは、Memory Burial機能で使用されるCloud Functions HTTPSコール可能関数のAPI仕様を定義します。

---

## API概要

### エンドポイント

| 関数名 | タイプ | タイムアウト | 説明 |
|--------|--------|-------------|------|
| `buryMemory` | HTTPSコール可能 | 30秒 | 記憶を埋葬し、クリスタルデータを生成 |

---

## 1. buryMemory

### 概要

ユーザーが入力した記憶テキストと位置情報を受け取り、以下の処理を実行します：

1. 入力バリデーション
2. クリスタルデータの生成（色と感情タイプ）
3. Firestoreへのデータ保存
4. 埋葬結果の返却

### エンドポイント情報

- **関数名**: `buryMemory`
- **メソッド**: HTTPSコール可能関数
- **認証**: 必須（Firebase Authentication）
- **タイムアウト**: 30秒
- **メモリ**: 512MB
- **リージョン**: asia-northeast1（東京）

---

### リクエスト

#### リクエスト形式

```typescript
{
  memoryText: string;      // 記憶テキスト（10～500文字）
  location: {
    latitude: number;      // 緯度（-90.0 ～ 90.0）
    longitude: number;     // 経度（-180.0 ～ 180.0）
  };
}
```

#### リクエスト例

```json
{
  "memoryText": "あの日の夕焼けがとても美しかった。友達と一緒に見た景色は今でも心に残っている。",
  "location": {
    "latitude": 35.6812,
    "longitude": 139.7671
  }
}
```

#### Flutterからの呼び出し例

```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<Map<String, dynamic>> buryMemory({
  required String memoryText,
  required double latitude,
  required double longitude,
}) async {
  try {
    final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
        .httpsCallable('buryMemory');
    
    final result = await callable.call({
      'memoryText': memoryText,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
      },
    });

    return result.data as Map<String, dynamic>;
  } on FirebaseFunctionsException catch (e) {
    print('Error code: ${e.code}');
    print('Error message: ${e.message}');
    rethrow;
  }
}
```

---

### レスポンス

#### 成功時のレスポンス（200 OK）

```typescript
{
  success: true;
  crystalId: string;       // UUID v4形式
  crystalColor: string;    // クリスタルの色（例: "blue", "red", "green", "purple"）
  emotionType: string;     // 感情タイプ（例: "joy", "sadness", "passion", "peace"）
  buriedAt: string;        // ISO 8601形式の日時
}
```

#### 成功レスポンス例

```json
{
  "success": true,
  "crystalId": "550e8400-e29b-41d4-a716-446655440000",
  "crystalColor": "blue",
  "emotionType": "joy",
  "buriedAt": "2025-11-29T12:34:56.789Z"
}
```

---

### エラーレスポンス

#### エラー形式

```typescript
{
  success: false;
  error: {
    code: string;          // エラーコード
    message: string;       // エラーメッセージ（日本語）
  }
}
```

#### エラーコード一覧

| コード | HTTP Status | 説明 | 対処方法 |
|--------|------------|------|---------|
| `unauthenticated` | 401 | 認証されていない | ログイン画面へ遷移 |
| `invalid-argument` | 400 | リクエストパラメータが無効 | 入力値を確認してリトライ |
| `deadline-exceeded` | 504 | タイムアウト | リトライボタンを表示 |
| `internal` | 500 | サーバー内部エラー | エラーメッセージを表示してリトライ |
| `resource-exhausted` | 429 | レート制限超過 | 「しばらく待ってからお試しください」と表示 |

#### エラーレスポンス例

```json
{
  "success": false,
  "error": {
    "code": "invalid-argument",
    "message": "記憶テキストは10文字以上500文字以下で入力してください"
  }
}
```

---

### バリデーションルール

Cloud Functions側で以下のバリデーションを実施します：

#### 1. 認証チェック

```typescript
if (!context.auth) {
  throw new functions.https.HttpsError(
    'unauthenticated',
    '認証が必要です。ログインしてください。'
  );
}
```

#### 2. memoryTextバリデーション

```typescript
const { memoryText, location } = data;

if (!memoryText || typeof memoryText !== 'string') {
  throw new functions.https.HttpsError(
    'invalid-argument',
    '記憶テキストを入力してください'
  );
}

if (memoryText.length < 10) {
  throw new functions.https.HttpsError(
    'invalid-argument',
    `記憶テキストは10文字以上必要です（現在: ${memoryText.length}文字）`
  );
}

if (memoryText.length > 500) {
  throw new functions.https.HttpsError(
    'invalid-argument',
    `記憶テキストは500文字以下にしてください（現在: ${memoryText.length}文字）`
  );
}
```

#### 3. locationバリデーション

```typescript
if (!location || typeof location !== 'object') {
  throw new functions.https.HttpsError(
    'invalid-argument',
    '位置情報が必要です'
  );
}

const { latitude, longitude } = location;

if (typeof latitude !== 'number' || typeof longitude !== 'number') {
  throw new functions.https.HttpsError(
    'invalid-argument',
    '位置情報の形式が不正です'
  );
}

if (latitude < -90 || latitude > 90) {
  throw new functions.https.HttpsError(
    'invalid-argument',
    `緯度は-90.0～90.0の範囲で指定してください（現在: ${latitude}）`
  );
}

if (longitude < -180 || longitude > 180) {
  throw new functions.https.HttpsError(
    'invalid-argument',
    `経度は-180.0～180.0の範囲で指定してください（現在: ${longitude}）`
  );
}
```

---

## Cloud Functions実装例

### TypeScript実装

**ファイルパス**: `functions/src/index.ts`

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { v4 as uuidv4 } from 'uuid';

admin.initializeApp();

/**
 * 記憶を埋葬し、クリスタルデータを生成
 */
export const buryMemory = functions
  .region('asia-northeast1')
  .runWith({
    timeoutSeconds: 30,
    memory: '512MB',
  })
  .https.onCall(async (data, context) => {
    // 1. 認証チェック
    if (!context.auth) {
      throw new functions.https.HttpsError(
        'unauthenticated',
        '認証が必要です。ログインしてください。'
      );
    }

    const userId = context.auth.uid;

    // 2. リクエストパラメータの取得
    const { memoryText, location } = data;

    // 3. バリデーション
    validateMemoryText(memoryText);
    validateLocation(location);

    // 4. レート制限チェック（オプション）
    await checkRateLimit(userId);

    // 5. クリスタルデータ生成
    const crystalId = uuidv4();
    const { crystalColor, emotionType } = await generateCrystalData(memoryText);

    // 6. Firestoreに保存
    const buriedAt = admin.firestore.Timestamp.now();
    await admin.firestore().collection('crystals').doc(crystalId).set({
      id: crystalId,
      memoryText,
      creatorUserId: userId,
      location: new admin.firestore.GeoPoint(
        location.latitude,
        location.longitude
      ),
      buriedAt,
      crystalColor,
      emotionType,
      isDiscovered: false,
      discoveredBy: [],
      createdAt: buriedAt,
      updatedAt: buriedAt,
    });

    // 7. レスポンス返却
    return {
      success: true,
      crystalId,
      crystalColor,
      emotionType,
      buriedAt: buriedAt.toDate().toISOString(),
    };
  });

/**
 * memoryTextのバリデーション
 */
function validateMemoryText(memoryText: any): void {
  if (!memoryText || typeof memoryText !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      '記憶テキストを入力してください'
    );
  }

  if (memoryText.length < 10) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `記憶テキストは10文字以上必要です（現在: ${memoryText.length}文字）`
    );
  }

  if (memoryText.length > 500) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `記憶テキストは500文字以下にしてください（現在: ${memoryText.length}文字）`
    );
  }
}

/**
 * locationのバリデーション
 */
function validateLocation(location: any): void {
  if (!location || typeof location !== 'object') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      '位置情報が必要です'
    );
  }

  const { latitude, longitude } = location;

  if (typeof latitude !== 'number' || typeof longitude !== 'number') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      '位置情報の形式が不正です'
    );
  }

  if (latitude < -90 || latitude > 90) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `緯度は-90.0～90.0の範囲で指定してください（現在: ${latitude}）`
    );
  }

  if (longitude < -180 || longitude > 180) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `経度は-180.0～180.0の範囲で指定してください（現在: ${longitude}）`
    );
  }
}

/**
 * レート制限チェック
 */
async function checkRateLimit(userId: string): Promise<void> {
  // TODO: Firestoreまたはメモリストアを使用してレート制限実装
  // 例: 5リクエスト/分、100リクエスト/日
}

/**
 * クリスタルデータ生成（色と感情タイプ）
 * 
 * 将来的にはVertex AI（Gemini）でテキスト分析を実施
 * MVP版ではシンプルなルールベース生成
 */
async function generateCrystalData(memoryText: string): Promise<{
  crystalColor: string;
  emotionType: string;
}> {
  // シンプルなキーワードベース判定（MVP版）
  const text = memoryText.toLowerCase();

  // 感情キーワード分析
  if (text.includes('嬉しい') || text.includes('楽しい') || text.includes('幸せ')) {
    return { crystalColor: 'yellow', emotionType: 'joy' };
  } else if (text.includes('悲しい') || text.includes('辛い') || text.includes('寂しい')) {
    return { crystalColor: 'blue', emotionType: 'sadness' };
  } else if (text.includes('怒り') || text.includes('情熱') || text.includes('熱い')) {
    return { crystalColor: 'red', emotionType: 'passion' };
  } else if (text.includes('穏やか') || text.includes('静か') || text.includes('癒し')) {
    return { crystalColor: 'green', emotionType: 'peace' };
  }

  // デフォルト
  return { crystalColor: 'purple', emotionType: 'mystery' };
}
```

---

## レート制限

### 実装方針

ユーザーごとにレート制限を設定し、過度なリクエストを防止します。

#### レート制限ルール

| 期間 | 制限 |
|------|------|
| 1分間 | 5リクエスト |
| 1日 | 100リクエスト |

#### 実装例（Firestore使用）

```typescript
interface RateLimitData {
  userId: string;
  requestCount: number;
  windowStart: admin.firestore.Timestamp;
}

async function checkRateLimit(userId: string): Promise<void> {
  const now = admin.firestore.Timestamp.now();
  const oneMinuteAgo = admin.firestore.Timestamp.fromMillis(
    now.toMillis() - 60 * 1000
  );

  const rateLimitRef = admin.firestore()
    .collection('rateLimits')
    .doc(userId);

  await admin.firestore().runTransaction(async (transaction) => {
    const doc = await transaction.get(rateLimitRef);

    if (!doc.exists) {
      // 初回リクエスト
      transaction.set(rateLimitRef, {
        userId,
        requestCount: 1,
        windowStart: now,
      });
      return;
    }

    const data = doc.data() as RateLimitData;

    if (data.windowStart.toMillis() < oneMinuteAgo.toMillis()) {
      // ウィンドウリセット
      transaction.update(rateLimitRef, {
        requestCount: 1,
        windowStart: now,
      });
    } else {
      // ウィンドウ内のリクエスト
      if (data.requestCount >= 5) {
        throw new functions.https.HttpsError(
          'resource-exhausted',
          'リクエスト制限を超過しました。しばらく待ってからお試しください。'
        );
      }

      transaction.update(rateLimitRef, {
        requestCount: data.requestCount + 1,
      });
    }
  });
}
```

---

## セキュリティ考慮事項

### 1. 認証の必須化

すべてのリクエストでFirebase Authenticationトークンを検証します。

### 2. 入力サニタイゼーション

XSS攻撃を防ぐため、入力テキストをエスケープします。

```typescript
function sanitizeText(text: string): string {
  return text
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
}
```

### 3. レート制限

ユーザーごとにリクエスト数を制限し、DDoS攻撃を防ぎます。

### 4. Firestoreセキュリティルール

Cloud Functionsだけでなく、Firestoreセキュリティルールでも書き込みを制限します（data-model.md参照）。

---

## デプロイ手順

### 1. 依存パッケージのインストール

```bash
cd functions
npm install
```

### 2. TypeScriptコンパイル

```bash
npm run build
```

### 3. Cloud Functionsデプロイ

```bash
firebase deploy --only functions:buryMemory
```

### 4. デプロイ確認

```bash
firebase functions:log
```

---

## テスト

### ユニットテスト例

```typescript
import { buryMemory } from '../src/index';
import * as admin from 'firebase-admin';
import * as test from 'firebase-functions-test';

const testEnv = test();

describe('buryMemory', () => {
  afterAll(() => {
    testEnv.cleanup();
  });

  it('should bury memory successfully', async () => {
    const data = {
      memoryText: 'あの日の夕焼けがとても美しかった。',
      location: {
        latitude: 35.6812,
        longitude: 139.7671,
      },
    };

    const context = {
      auth: {
        uid: 'test-user-123',
      },
    };

    const result = await buryMemory(data, context);

    expect(result.success).toBe(true);
    expect(result.crystalId).toBeDefined();
    expect(result.crystalColor).toBeDefined();
    expect(result.emotionType).toBeDefined();
  });

  it('should throw error for invalid memoryText', async () => {
    const data = {
      memoryText: '短い', // 10文字未満
      location: {
        latitude: 35.6812,
        longitude: 139.7671,
      },
    };

    const context = {
      auth: {
        uid: 'test-user-123',
      },
    };

    await expect(buryMemory(data, context)).rejects.toThrow();
  });
});
```

---

## まとめ

このAPI仕様により、以下が実現されます：

1. ✅ セキュアな認証と認可
2. ✅ 包括的なバリデーション
3. ✅ レート制限によるリソース保護
4. ✅ 明確なエラーハンドリング
5. ✅ テスト可能な設計

次のステップでは、このAPIを呼び出すFlutter側のRepository実装を定義します。

