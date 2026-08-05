---
{
  "schema_version": 1,
  "id": "header.header-xb",
  "kind": "header",
  "title": "XB",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Encoding Forms",
  "sources": {
    "davincioo": "header/XB.md"
  }
}
---
# XB

`XB`指令用于系统调用块中发起调用请求，支持动态调用已注册的块体，确保模块化的安全调用结构。除此之外，XB指令还可以定义调用的目标特权级和功能参数。

## 汇编格式

```asm
   XB {acr-id}, {c-id}
```
两个参数用于定义跨模块调用的目标：

- **acr-id**参数指定目标特权级和所属的ACR模块，使用规则如下：
   - **当前处于ACR0**：目标ACR只能为ACR0。
   - **当前处于ACR1**：目标ACR可以为ACR0或ACR1。
   - **当前处于ACR2**：目标ACR可以为ACR0、ACR1或ACR2。
- **c-id**：索引块体的功能ID（有效范围0-127），在`CAC_TABLE`中查找目标块体信息。

## 编码格式

> 原 Linx 图片引用已省略；编码图用本页 bit-level 表格表达。

- ACR-ID编码{acr-id}，编码对于不同当前ACR的含义不同：
   * 当前为ACR0
      - 目标特权级为ACR0，则ACR-ID字段编码为0
      - 其他编码无效
   * 当前为ACR1
      - 目标特权级为ACR0，则ACR-ID字段编码为0
      - 目标特权级为ACR1，则ACR-ID字段编码为1
      - 其他编码无效
   * 当前为ACR2
      - 目标特权级为ACR0，则ACR-ID字段编码为0
      - 目标特权级为ACR1，则ACR-ID字段编码为1
      - 目标特权级为ACR2，则ACR-ID字段编码为2
      - 其他编码无效
- CROSS-BID 编码{c-id}。

## Bit-level Encoding

### `XB` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:25]` | `CROSS-BID` | 7 | `` |
| `[24:15]` | `ACR-ID` | 10 | `` |
| `[14:12]` | `Func` | 3 | `6` |
| `[11:7]` | `31` | 5 | `31` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |
