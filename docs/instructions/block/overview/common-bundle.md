---
{
  "schema_version": 1,
  "id": "header.header-comblockintro",
  "kind": "header",
  "title": "Common Bundle",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Overview",
  "sources": { "davincioo": "header/ComBlockIntro.md" }
}
---
# Common Bundle

一般通用块由 `BSTART` 类指令开启，通过 `BSTOP` 或下一条提交型指令结束。在这两个边界之间，其他 Block/Header 指令补充块属性、操作数、维度与块体位置信息。

## 一体块

```asm
BSTART
...                 # optional Block/Header descriptors
body_instruction_0
body_instruction_1
BSTOP
```

## 分离块

```asm
BSTART
...                 # optional Block/Header descriptors
B.TEXT .body
BSTOP

.body:
body_instruction_0
body_instruction_1
BSTOP
```

`B.TEXT` 只用于需要分离块体的形式。各执行类别是否允许一体块、分离块以及具体终止规则，以对应的 `BSTART.*` 页面和 [Block/Header Model](./block-header-model.md) 为准。

## 提交行为

- `BSTART` 提交前一个块并初始化当前块状态。
- `BSTOP` 提交并结束当前块。
- 推测执行期间，每个块维护独立的临时状态；错误路径的状态不会进入架构提交。

不同长度的开始编码见 `C.BSTART`、`BSTART`、`HL.BSTART` 和 `L.BSTART` 页面；公开范围见 [Block/Header Model](./block-header-model.md)。
