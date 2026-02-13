# Codex Pro API

将 **Codex**（gpt-5.3-codex）以 **OpenAI 兼容 API** 形式暴露，可在 Cline、Cursor 等支持 OpenAI 接口的客户端中使用。

**For English, see [README.md](README.md).**

---

## 演示说明

**账号页 — 通过「使用 Codex 登录」添加账号（OAuth）：**

![账号页](accounts.png)

**模型页 — 查看可用模型与额度：**

![模型页](models.png)

---

## 前置条件

- **Node.js** 18 或更高

## 启动服务

**一键启动（全局安装，npm 会自动安装依赖）：**

```bash
npm install -g codex-proapi
codex-proapi
```

**或在项目目录运行：**

```bash
npm install
npm start
```

然后在浏览器打开 **http://localhost:1455/**，点击「使用 Codex 登录」通过 OAuth 添加账号。默认端口为 **1455**，可通过 `PORT` 环境变量修改。全局安装时，账号与用量数据均保存在 `~/.codex-proapi/`。

## 在客户端中使用（Cline、Cursor 等）

| 配置项     | 填写内容 |
|------------|----------|
| **Base URL** | `http://localhost:1455`（或你的主机与端口） |
| **模型**     | `gpt-5.3-codex`（或 `gpt-5.2-codex`、`gpt-5-codex`、`gpt-5`、`gpt-4`） |
| **API Key**  | 任意填写（不校验；认证来自已配置的 Codex 账号） |

1. 在 **http://localhost:1455/** 点击「使用 Codex 登录」添加账号。
2. 在客户端中按上表设置 Base URL 和模型，API Key 随意。
3. 照常发起请求即可，代理会使用你配置的账号。

无需改代码或做服务端配置，只需在配置页添加账号即可使用。

## 部署与「绑定 API」报 403

若服务通过 **反向代理**（如 Nginx、Cloudflare）对外提供 HTTPS，而用户在前台用 `https://你的域名` 打开并点击「使用 Codex 登录」时，最后一步**绑定 API** 可能报错（如 `Token exchange failed: 403`）。原因是：OAuth 回调地址必须与浏览器实际访问的地址一致。

**本服务默认已信任反向代理**（`trust proxy`），会优先使用请求头中的 `X-Forwarded-Proto` 和 `X-Forwarded-Host` 来生成 OAuth 回调地址。因此只要代理正确转发这两项，**通常无需配置**即可正常绑定：

- **Nginx** 示例：
  ```nginx
  proxy_set_header X-Forwarded-Proto $scheme;
  proxy_set_header X-Forwarded-Host $host;
  ```
- **Cloudflare** 等 CDN 一般会自动添加上述头。

若代理未转发这些头、或仍出现 403，可显式设置公开地址：

- **方式一**：`PUBLIC_URL=https://你的域名`（不要末尾斜杠）
- **方式二**：`OAUTH_REDIRECT_URI=https://你的域名/auth/callback`

重启后启动日志会打印当前 OAuth 回调地址；请确保用户**始终通过该域名**打开并登录。

## 多轮对话与后端格式说明

本服务上游为 ChatGPT 的 Codex 后端（`chatgpt.com/backend-api/codex/responses`）。该后端对 **assistant** 消息的 content 只接受 `output_text` 等「输出」类型；若对 assistant 使用 `input_text` 会返回 400。因此代理采用折中方案：**不单独提交 assistant 消息**，而是把整段对话（含 user / assistant / system）拼成一段带 `User:`、`Assistant:`、`System:` 前缀的文本，作为**一条 user 的 input_text** 发给后端。客户端仍按 OpenAI 格式传 `messages: [{role, content}, ...]`，多轮对话由代理自动完成上述转换。

## 功能说明

- **多账号轮询与故障切换** — 请求在多账号间轮询；某账号失败时自动切换下一个。
- **配置页** — 仪表盘、模型（额度）、账号（OAuth 登录）、日志（级别筛选、搜索、清空）、设置（语言、Base URL）。数据每 5 秒自动刷新。
- **响应式界面** — 支持桌面与手机；小屏下侧栏收起到菜单。
- **中英双语** — 界面与日志文案支持英文与简体中文。

## 使用 [free.violetteam.cloud](https://free.violetteam.cloud/) 接收验证码

若使用 [free.violetteam.cloud](https://free.violetteam.cloud/) 接收验证邮件（如注册 ChatGPT/Codex 小号），验证码到达可能稍慢，请耐心等待。若长时间未收到，请点击**重发验证码**。
