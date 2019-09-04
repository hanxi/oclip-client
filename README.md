# oclip-client

[open clipboard] 远程剪切板客户端

Server Website:  https://oclip.hanxi.info/

## Build

- In windows

```
cd platform\win
build.bat
```

- In Linux

```
cd platform/linux
sh build.sh
```

## Develop

- In Windows

```
run.bat
```

- In Linux

```
sh run.sh
```

## Requirement

- In Windows: VS2017 (C/C++)
- In Linux: GCC, libopenssl

## Run config

- Config file is `~/.oclip`
```
token = eyJhbGciOiJI.eyJleHAiOjE1Njc5NjM4TcifQ.rWe411UYB5VB
passwd = password
domain = oclip.hanxi.info
```

## TODO

- [x] Linux platform
- [x] Windows platorm: Set auto start
- [x] Windows platorm: Open config file
- [ ] Windows platorm: Change Logo

## Others

blog: https://blog.hanxi.info/?p=37
