## CI/CD環境構成

### ブランチ戦略
- `main` : 本番環境。直接push禁止。PRのみマージ可
- `develop` : 開発統合ブランチ。featureブランチのマージ先
- `feature/*` : 機能ごとに切るブランチ

### 開発フロー
1. `feature/*` ブランチで開発
2. `develop` へPR作成 → CIが自動実行
3. レビュー & マージ
4. `develop` → `main` へPR作成 → CIが自動実行
5. マージ → 自動デプロイ

### 技術スタック
- **言語 / FW** : Ruby on Rails 8.1.2
- **Ruby** : `.ruby-version` 参照
- **DB（開発・テスト）** : SQLite3
- **DB（本番）** : PostgreSQL 18（Render.com）
- **CI/CD** : GitHub Actions
- **デプロイ先** : Render.com

### GitHub Actions ワークフロー（`.github/workflows/ci.yml`）

#### トリガー
- `main` / `develop` への push
- `main` / `develop` へのPull Request
- 手動実行（`workflow_dispatch`）

#### jobsの構成

**testジョブ**
- ubuntu-latest で実行
- `RAILS_ENV: test`
- SQLiteでDB作成 & マイグレーション実行
- `bundle exec rails test` でテスト実行

**deployジョブ**
- `test` ジョブ成功後にのみ実行（`needs: test`）
- `main` への push 時のみ実行
- Render APIにPOSTリクエストを送信してデプロイをトリガー

### Render.com 設定
- **Auto-Deploy** : 無効（GitHub Actions経由でのみデプロイ）
- **Build Command** : `bundle install && bundle exec rails db:migrate RAILS_ENV=production`
- **Start Command** : `bundle exec rails server -b 0.0.0.0`

### 環境変数

#### Render.com（本番）
| Key | 内容 |
|---|---|
| `DATABASE_URL` | PostgreSQL接続URL（`postgres://`始まり） |
| `RAILS_ENV` | `production` |
| `RAILS_MASTER_KEY` | `config/master.key` の内容 |
| `RAILS_SERVE_STATIC_FILES` | `true` |

#### GitHub Actions Secrets
| Key | 内容 |
|---|---|
| `RENDER_API_KEY` | RenderのAPIキー |
| `RENDER_SERVICE_ID` | RenderのサービスID |

### database.yml 構成方針
- `development` : SQLite3（ローカルPostgreSQL不要）
- `test` : SQLite3（CI上でPostgreSQL不要）
- `production` : `DATABASE_URL` 環境変数で接続（`postgres://`始まりであること）

### 注意事項
- `DATABASE_URL` は `postgresql://` ではなく `postgres://` 始まりにすること（Railsが認識しないため）
- 本番の `solid_cache` / `solid_queue` / `solid_cable` も `url: <%= ENV["DATABASE_URL"] %>` を明示すること