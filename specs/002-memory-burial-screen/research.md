# Research: Memory Burial Screen実装

**作成日**: 2025-11-29  
**機能**: Memory Burial Screen  
**ブランチ**: `002-memory-burial-screen`

## 概要

本ドキュメントは、Memory Burial Screen機能の実装における技術的な決定事項と調査結果をまとめたものです。spec.mdの要件に基づき、必要な技術スタックとベストプラクティスを定義します。

## 機能要件の理解

spec.mdから抽出した主要機能：

1. **テキスト入力とバリデーション**: 10～500文字の記憶テキスト入力
2. **テキスト分解アニメーション**: 文字単位で分解され、ボタンに吸い込まれる視覚効果
3. **サーバーリクエスト**: 記憶テキスト + GPS座標を送信（アニメーションと同時実行）
4. **成功フロー**: 成功メッセージ2秒表示 → マップ画面遷移
5. **エラーハンドリング**: ネットワークエラー時のリトライ機能
6. **位置情報統合**: package/coreモジュールから位置データを取得

**重要な理解**:
- この画面はAI生成やクリスタル画像を**表示しない**
- サーバーから返されたクリスタルデータは保存するが、ユーザーには見せない（FR-019）
- マップ画面に遷移した後、他のユーザーが発見可能になる

---

## 技術スタック決定

### 1. アニメーション実装

**決定**: Flutter標準のAnimationControllerとCustomPainterを使用

**根拠**:
- テキストを文字単位で分解し、各文字をAnimatedPositionedで制御
- パーティクル効果はCustomPainterで実装（高パフォーマンス）
- 外部依存を最小化（LottieやRiveは不要）
- 60fpsを維持可能

**実装アプローチ**:

```dart
// 各文字を個別のウィジェットとして配置
List<Widget> _buildCharacterWidgets() {
  return memoryText.split('').map((char) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 500),
      left: _isAnimating ? buttonPosition.dx : initialPosition.dx,
      top: _isAnimating ? buttonPosition.dy : initialPosition.dy,
      child: Opacity(
        opacity: _isAnimating ? 0.0 : 1.0,
        child: Text(char),
      ),
    );
  }).toList();
}
```

**代替案**:
- Lottie: デザイナー作成のアニメーション再生可能だが、今回は動的テキスト分解が必要なため不適
- Rive: より高度だが学習コスト高、オーバースペック
- シェーダー: 最高パフォーマンスだが開発コスト高

**決定理由**: シンプルで十分なパフォーマンスを発揮し、プロジェクト標準のFlutter技術スタックに適合

---

### 2. サーバーAPI統合

**決定**: Cloud Functions（HTTPSコール可能関数）を使用

**根拠**:
- プロジェクトで既にFirebaseを使用
- `cloud_functions`パッケージがfeature/pubspec.yamlに含まれている
- 認証トークンは自動的にCloud Functionsに送信される
- タイムアウトとエラーハンドリングが組み込み済み

**API設計**:

```dart
final callable = FirebaseFunctions.instance.httpsCallable('buryMemory');
final result = await callable.call({
  'memoryText': memoryText,
  'location': {
    'latitude': latitude,
    'longitude': longitude,
  },
});

// レスポンス例
{
  'success': true,
  'crystalId': 'xxx',
  'color': 'blue',     // 保存するが表示しない
  'emotionType': 'joy' // 保存するが表示しない
}
```

**エンドポイント仕様** (Cloud Functions側):
- 関数名: `buryMemory`
- 認証: 必須（Firebase Authentication）
- タイムアウト: 30秒
- レート制限: 5リクエスト/分、100リクエスト/日

**代替案**:
- REST API: カスタムバックエンド必要、認証管理が複雑
- Firestore直接書き込み: サーバー側ロジック（AI生成など）を実行できない

---

### 3. 位置情報取得

**決定**: package/coreモジュールのLocationRepositoryを使用（既存実装活用）

**根拠**:
- FR-025: 「System MUST use location data from package/core module」
- FR-026: 「System MUST work with mock location data during development」
- プロジェクトの既存アーキテクチャに準拠

**実装方針**:

```dart
// packages/core/lib/domain/repositories/location_repository.dart（想定）
abstract class LocationRepository {
  Future<GeoLocation> getCurrentLocation();
  Future<bool> requestPermission();
  Future<bool> isPermissionGranted();
}

// 使用例
final location = await ref.read(locationRepositoryProvider).getCurrentLocation();
```

**エラーハンドリング**:
- 位置情報権限拒否 → エラーメッセージ表示、設定画面への誘導
- GPS精度低い → 警告表示だが埋葬は許可
- タイムアウト（10秒） → エラーメッセージとリトライ

**代替案**:
- geolocatorパッケージ直接使用: アーキテクチャ違反、coreモジュールに実装すべき

---

### 4. 状態管理

**決定**: Riverpod（既存プロジェクト標準）

**根拠**:
- プロジェクトで既に使用（flutter_riverpod: ^3.0.3）
- 非同期処理を`AsyncValue`で簡潔に管理
- 依存性注入が容易
- 既存のhome/haikuパッケージと一貫性

**状態設計**:

```dart
// メモリテキストの状態
final memoryTextProvider = StateProvider<String>((ref) => '');

// 埋葬処理の状態
final buryMemoryProvider = FutureProvider.autoDispose<void>((ref) async {
  final memoryText = ref.watch(memoryTextProvider);
  final location = await ref.read(locationRepositoryProvider).getCurrentLocation();
  
  final useCase = ref.read(buryMemoryUseCaseProvider);
  await useCase.call(memoryText: memoryText, location: location);
});

// ボタン有効化の状態
final isButtonEnabledProvider = Provider<bool>((ref) {
  final text = ref.watch(memoryTextProvider);
  return text.length >= 10 && text.length <= 500;
});
```

---

### 5. アニメーションとAPI呼び出しの同期

**決定**: Futureを並列実行し、両方が完了するまで待機

**根拠**:
- FR-012: 「System MUST send API request to server simultaneously with animation start」
- FR-014: 「System MUST wait for server response in background after animation completes」

**実装パターン**:

```dart
Future<void> _handleBuryAction() async {
  setState(() => _isAnimating = true);
  
  // アニメーションとAPIリクエストを並列実行
  final results = await Future.wait([
    _animationController.forward().orCancel, // 2秒
    _buryMemoryApiCall(),                     // 最大30秒
  ]);
  
  setState(() => _isAnimating = false);
  
  // 成功メッセージ表示
  _showSuccessMessage();
  
  // 2秒後にマップ画面へ遷移
  await Future.delayed(Duration(seconds: 2));
  Navigator.pushReplacementNamed(context, '/map');
}
```

**エッジケース対応**:
- アニメーション完了（2秒）後もAPIレスポンス待機中 → バックグラウンドで待機（ローディング表示なし）
- APIが先に完了した場合 → アニメーション完了まで待機
- APIエラー時 → アニメーション中断、エラーメッセージ表示

---

### 6. エラーハンドリングとリトライ

**決定**: 段階的なエラー処理とユーザーフレンドリーなリトライUI

**エラー分類**:

| エラータイプ | 原因 | 対処方法 |
|------------|------|---------|
| ネットワークエラー | オフライン、接続不安定 | リトライボタン表示、入力テキスト保持 |
| タイムアウト | サーバー処理遅延 | リトライボタン表示（30秒後） |
| 位置情報エラー | 権限拒否、GPS無効 | 設定画面への誘導リンク |
| サーバーエラー | 500エラー、AI生成失敗 | エラーメッセージとリトライ |
| バリデーションエラー | 文字数不正 | リアルタイムバリデーションで事前防止 |

**リトライ実装**:

```dart
int _retryCount = 0;
final maxRetries = 3;

Future<void> _buryWithRetry() async {
  try {
    await _buryMemoryApiCall();
  } on NetworkException {
    if (_retryCount < maxRetries) {
      _retryCount++;
      // 指数バックオフ: 1秒、2秒、4秒
      await Future.delayed(Duration(seconds: pow(2, _retryCount - 1)));
      return _buryWithRetry();
    } else {
      _showErrorDialog('ネットワークエラーが発生しました。後でもう一度お試しください。');
    }
  }
}
```

**FR-023対応**: エラー時に入力テキストを保持（再入力不要）

---

### 7. 重複埋葬防止

**決定**: ローカルフラグとFirestoreトランザクションの組み合わせ

**根拠**:
- FR-015: 「System MUST prevent duplicate requests if user taps button multiple times」
- SC-006: 「System prevents 100% of duplicate burial attempts」

**実装**:

```dart
// Presentation層
bool _isBurying = false;

void _onBuryButtonPressed() {
  if (_isBurying) return; // 早期リターン
  
  _isBurying = true;
  _handleBuryAction().whenComplete(() {
    _isBurying = false;
  });
}

// Data層（Repository）
Future<void> buryMemory(...) async {
  final crystalId = Uuid().v4();
  
  // Firestoreトランザクションで一意性保証
  await _firestore.runTransaction((transaction) async {
    final docRef = _firestore.collection('crystals').doc(crystalId);
    final snapshot = await transaction.get(docRef);
    
    if (snapshot.exists) {
      throw DuplicateMemoryException();
    }
    
    transaction.set(docRef, crystalData);
  });
}
```

---

## データモデル設計（概要）

### エンティティ構造

```dart
class MemoryBurialRequest {
  final String memoryText;
  final GeoLocation location;
  final DateTime timestamp;
}

class MemoryBurialResult {
  final String crystalId;
  final String color;        // 保存するが表示しない
  final String emotionType;  // 保存するが表示しない
  final DateTime buriedAt;
}

class GeoLocation {
  final double latitude;
  final double longitude;
}
```

### Firestoreデータ構造（想定）

```
crystals/{crystalId}
  - memoryText: string
  - creatorUserId: string
  - location: GeoPoint
  - buriedAt: Timestamp
  - color: string
  - emotionType: string
  - isDiscovered: boolean (初期値: false)
```

---

## ベストプラクティス

### 1. テキスト入力バリデーション

**リアルタイムフィードバック**:

```dart
TextField(
  maxLength: 500,
  inputFormatters: [LengthLimitingTextInputFormatter(500)],
  decoration: InputDecoration(
    hintText: '記憶を入力してください（10～500文字）',
    counterText: '${text.length}/500',
    errorText: text.isNotEmpty && text.length < 10
        ? '最低10文字必要です'
        : null,
  ),
  onChanged: (value) {
    ref.read(memoryTextProvider.notifier).state = value;
  },
)
```

### 2. アニメーション最適化

**バッテリー考慮**:
- 60fpsを目標とするが、低バッテリー時は30fpsに削減
- アニメーション完了後は即座にリソース解放

### 3. セキュリティ考慮事項

**Cloud Functions**:
- すべてのリクエストで認証チェック必須
- レート制限実装（5リクエスト/分）
- 入力テキストのサニタイゼーション（XSS対策）

**Firestore Security Rules**:

```javascript
match /crystals/{crystalId} {
  allow create: if request.auth != null
                && request.resource.data.creatorUserId == request.auth.uid
                && request.resource.data.memoryText.size() >= 10
                && request.resource.data.memoryText.size() <= 500;
  allow read: if request.auth != null;
  allow update, delete: if false; // 埋葬後は変更不可
}
```

---

## パフォーマンス要件

### 目標値

- **SC-001**: 埋葬プロセス全体: 30秒以内（通常ケース）
- **SC-002**: アニメーション完了: 2秒
- **SC-003**: 文字数バリデーション: 100ms以内
- **SC-004**: サーバーリクエスト成功率: 95%以上
- **SC-007**: 成功メッセージ表示時間: 正確に2秒

### タイムアウト設定

- API呼び出し: 30秒
- 位置情報取得: 10秒
- アニメーション: 2秒（固定）

---

## テスト戦略

### ユニットテスト

- **Domain層**: UseCaseのビジネスロジック検証（モックRepository使用）
- **Data層**: Repositoryのデータ変換とエラーハンドリング
- **Validation**: 境界値テスト（9文字、10文字、500文字、501文字）

### ウィジェットテスト

- テキスト入力とバリデーション
- ボタン有効化/無効化ロジック
- エラーメッセージ表示

### インテグレーションテスト

- エンドツーエンドフロー（入力 → アニメーション → API → 成功）
- エラーシナリオ（ネットワークエラー、位置情報エラー）

---

## 未解決事項

### MVP後対応

1. **オフライン対応**: ネットワーク復帰時に自動リトライ
2. **アクセシビリティ**: スクリーンリーダー対応
3. **多言語対応**: 現在は日本語優先
4. **コンテンツモデレーション**: 不適切なテキストフィルタリング（サーバー側）

---

## 依存パッケージ

以下のパッケージが必要（既存のfeature/pubspec.yamlで確認済み）:

```yaml
dependencies:
  # State Management
  flutter_riverpod: ^3.0.3
  
  # Firebase
  cloud_functions: ^6.0.1
  cloud_firestore: ^6.1.0
  
  # Utilities
  equatable: ^2.0.5
  
  # Core package
  core:
    path: ../core
```

**追加パッケージ不要**: 既存の依存関係で全機能を実装可能

---

## まとめ

Memory Burial Screen機能は、既存のFlutterクリーンアーキテクチャとFirebaseスタックに適合する形で設計されています。主要な技術的決定事項：

1. ✅ Flutter標準アニメーションで文字分解エフェクト実装
2. ✅ Cloud Functionsで埋葬API実装
3. ✅ package/coreの位置情報モジュール活用
4. ✅ Riverpodで状態管理と依存性注入
5. ✅ アニメーションとAPI並列実行
6. ✅ 重複防止とエラーハンドリング

すべての機能要件（FR-001～FR-026）とエッジケースに対応する技術的基盤が整いました。次のフェーズでデータモデルとAPIコントラクトの詳細を設計します。

