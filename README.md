# 个人保险智能投保顾问iOS应用

## 项目简介
一款基于生成式AI的智能保险服务平台，支持个性化保险推荐、AI辅助审核和可视化决策分析。采用分层架构设计，覆盖iOS客户端、微服务后端和AI模型服务。


## 开发环境

操作系统： MacOS Sequoia 15.2
开发平台： Xcode 16.2
模拟器设备操作系统： iOS 18.2
编程语言： Swift 6.0.3


## 后端服务

### NocoDB无代码平台， 提供DBaaS服务， 包括Rest API

控制台URL，（public access， ready only），维护用户，产品，保单table数据
https://app.nocodb.com/p/nau-cit693

对应的Rest API SwaggerUI
https://app.nocodb.com/api/v2/meta/bases/pbz0v7s9slk0ak1/swagger


## 运行测试

### 测试账号

投保代理员：（不可注册，由后台NocoDB创建管理）
用户名： Agent
密码： 123456

客户：（亦可直接在app注册新用户）
用户名： user
密码： 123456


### 本地运行

Xcode导入本项目文件，可直接运行，无需安装额外依赖插件。
