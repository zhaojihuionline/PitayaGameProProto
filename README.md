# Protobuf 代码生成工具

这个目录包含了项目的 Protocol Buffers 代码生成工具，支持生成 Go 和 C# 代码。

## 📋 目录结构

```
protobuf/
├── proto/              # 原始 .proto 文件
│   ├── common/        # 公共定义
│   ├── battlesvr/     # 战斗服务
│   ├── gamesvr/       # 游戏服务
│   ├── gateway/       # 网关服务
│   ├── loginsvr/      # 登录服务
│   ├── matchmakingsvr/# 匹配服务
│   └── configsvr/     # 配置服务
├── pb/                # 生成的代码
│   ├── golang/       # Go 代码
│   └── csharp/       # C# 代码
├── generate_go.bat    # Windows Go 代码生成脚本
├── generate_go.sh     # Unix Go 代码生成脚本
├── generate_csharp.bat # Windows C# 代码生成脚本
└── generate_csharp.sh  # Unix C# 代码生成脚本
```

## 🛠️ 环境准备

### 1. 下载 Protocol Buffers 编译器

从 [GitHub Releases](https://github.com/protocolbuffers/protobuf/releases) 下载相应平台的版本：

#### Windows (64位)
- **文件名**：`protoc-33.2-win64.zip`
- **下载链接**：https://github.com/protocolbuffers/protobuf/releases/download/v33.2/protoc-33.2-win64.zip

#### Linux (x86_64)
- **文件名**：`protoc-33.2-linux-x86_64.zip`
- **下载链接**：https://github.com/protocolbuffers/protobuf/releases/download/v33.2/protoc-33.2-linux-x86_64.zip

#### 其他平台
访问 [GitHub Releases 页面](https://github.com/protocolbuffers/protobuf/releases/tag/v33.2) 下载适合您平台的版本。

### 2. 安装步骤

1. 解压下载的 protoc 压缩包（如 `protoc-33.2-win64.zip` 或 `protoc-33.2-linux-x86_64.zip`）
2. 将 `bin/` 目录添加到系统 PATH 环境变量
3. 验证安装：
   ```bash
   protoc --version
   # 应该显示：libprotoc 33.2
   ```

### 3. 安装 Go 代码生成器

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.10
```

验证安装：
```bash
protoc-gen-go --version
# 应该显示：protoc-gen-go.exe v1.36.10
```

## 🚀 使用方法

### 生成 Go 代码

#### Windows
```bash
./generate_go.bat
```

#### Unix/Linux/macOS
```bash
./generate_go.sh
```

### 生成 C# 代码

#### Windows
```bash
./generate_csharp.bat
```

#### Unix/Linux/macOS
```bash
./generate_csharp.sh
```

## 📝 Proto 文件规范

### 文件结构
- 使用 `proto3` 语法：`syntax = "proto3";`
- 每个服务一个独立的 `.proto` 文件
- 公共定义放在 `common/` 目录下

### Go 包配置
每个 proto 文件需要指定 Go 包路径：

```protobuf
option go_package = "pitaya-game/protos/protobuf/pb/golang/servicename;servicenamepb";
```

例如：
```protobuf
option go_package = "pitaya-game/protos/protobuf/pb/golang/gamesvr;gamesvrpb";
```

### C# 命名空间
```protobuf
option csharp_namespace = "PitayaGame.ServiceName";
```

## 🔧 脚本说明

### generate_go.bat / generate_go.sh
- 递归查找所有 `.proto` 文件
- 使用 `protoc --go_out` 生成 Go 代码
- 支持路径重写：`--go_opt=paths=source_relative`

### generate_csharp.bat / generate_csharp.sh
- 生成 C# 代码
- 使用标准的 `protoc --csharp_out` 命令

## 📂 输出目录

- **Go 代码**：`pb/golang/`
- **C# 代码**：`pb/csharp/`

生成的代码会按照 proto 文件的目录结构组织。

## 🔍 故障排除

### protoc 命令未找到
确保 protoc 已添加到 PATH：
```bash
echo $PATH  # Unix
$env:PATH   # PowerShell
```

### protoc-gen-go 未找到
确保 GOPATH/bin 在 PATH 中：
```bash
go env GOPATH
# 将 $GOPATH/bin 添加到 PATH
```

### 生成失败
检查 proto 文件语法：
```bash
protoc --proto_path=. --dry_run proto_file.proto
```

## 📚 相关链接

- [Protocol Buffers 官方文档](https://developers.google.com/protocol-buffers)
- [Go Protocol Buffers 指南](https://developers.google.com/protocol-buffers/docs/gotutorial)
- [C# Protocol Buffers 指南](https://developers.google.com/protocol-buffers/docs/csharptutorial)

## 🏷️ 版本信息

- **protoc**: 33.2
- **protoc-gen-go**: v1.36.10
- **Protocol Buffers**: v1.35.2 (Go 库)
