# 🚀 Render 服务保活器

自动唤醒 Render 免费服务，防止它们进入休眠状态。

## 📋 功能特性

- ✅ **自动唤醒**: 每10分钟自动 ping 所有服务
- 📧 **智能邮件通知**: 失败时发送详细的 HTML 邮件报告
- 🎯 **一键唤醒**: 提供 Web 界面和脚本进行手动唤醒
- 📊 **详细统计**: 显示成功/失败的服务数量和具体信息

## 🛠️ 配置的服务

当前监控的服务列表：

- **HuskyAI 主服务**: https://huskyAI.bitsleep.cn
- **HuskyAI 健康检查**: https://huskyAI.bitsleep.cn/api/health  
- **BitSleep 主站**: https://bitsleep.cn
- **Unity WebGL**: https://unity-webgl.onrender.com
- **BitSleep Render**: https://bitsleep-5zg5.onrender.com

## 📧 邮件通知功能

### 优化后的邮件内容包含：

1. **清晰的统计信息**: 显示失败数量和总数量
2. **具体失败服务**: 列出哪些服务无法访问
3. **快速操作按钮**:
   - 查看详细日志
   - 手动重新唤醒
   - 直接访问各个服务的链接
4. **精美的 HTML 样式**: 专业的邮件外观

### 邮件示例主题：
```
🚨 Render服务唤醒失败 (2/5)
```

## 🎯 手动唤醒选项

### 1. GitHub Actions 手动触发
- 访问: [Actions 页面](https://github.com/LiWinston/cron-waker/actions/workflows/render-waker.yml)
- 点击 "Run workflow" 按钮

### 2. Web 界面 (wakeup.html)
- 打开 `wakeup.html` 文件
- 提供美观的界面和一键唤醒功能
- 实时显示唤醒状态和响应时间

### 3. 命令行脚本
```bash
# 唤醒所有服务
bash scripts/manual_wakeup.sh

# 唤醒单个服务
bash scripts/manual_wakeup.sh https://huskyAI.bitsleep.cn
```

## ⚙️ GitHub Secrets 配置

需要在 GitHub 仓库中配置以下 Secrets：

- `MAIL_USERNAME`: QQ邮箱用户名
- `MAIL_PASSWORD`: QQ邮箱应用专用密码

## 🔧 自定义配置

### 添加新服务
在以下文件中添加新的 URL：

1. `scripts/render_waker.sh` - 主要唤醒脚本
2. `scripts/manual_wakeup.sh` - 手动唤醒脚本  
3. `wakeup.html` - Web 界面

### 修改唤醒频率
在 `.github/workflows/render-waker.yml` 中修改 cron 表达式：
```yaml
schedule:
  - cron: "*/10 * * * *"  # 每10分钟执行一次
```

## 📊 监控和日志

- **GitHub Actions 日志**: 查看每次执行的详细日志
- **邮件通知**: 失败时自动发送包含错误信息的邮件
- **实时状态**: Web 界面提供实时的唤醒状态反馈

## 🚀 部署说明

1. Fork 此仓库
2. 配置 GitHub Secrets
3. 启用 GitHub Actions
4. 根据需要修改服务列表

## 📝 更新日志

### v2.0 (当前版本)
- ✅ 新增详细的失败服务信息
- ✅ 优化邮件模板，支持 HTML 格式
- ✅ 添加一键唤醒按钮和快速链接
- ✅ 创建 Web 界面进行手动唤醒
- ✅ 改进错误处理和日志记录

### v1.0
- ✅ 基础的服务唤醒功能
- ✅ 简单的邮件通知

---

💡 **提示**: 如果你收到失败邮件，可以直接点击邮件中的按钮进行快速处理，或者使用提供的 Web 界面进行手动唤醒。
