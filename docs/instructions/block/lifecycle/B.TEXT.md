---
{
  "schema_version": 1,
  "id": "header.header-b.text",
  "kind": "header",
  "title": "B.TEXT",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Lifecycle & Control",
  "sources": {
    "davincioo": "header/B.TEXT.md"
  }
}
---
# B.TEXT

## 说明

块体偏移(*Block Text*)
本指令用于分离块块头中指定**块体的位置**，块体位置通过程序标签表达。

## 汇编语法

```asm
    B.TEXT label
```

## 汇编符号

- label表示块体起始位置的地址标签，其相对于本指令PC的偏移量除以2后编码于simm25字段。

## 编码格式

> 原 Linx 图片引用已省略；编码图用本页 bit-level 表格表达。

## 块体起止PC

**块体的起始PC**
```
    // 块体中第一条微指令的TPC
    BTextOffset = simm25 << 1;
    START_TPC = B.TEXT_PC + BTextOffset;
```
**块体的结束PC**：分离块块体结束由BSTOP指令指示，块体的结束PC为BSTOP指令的PC。

## 备注

- 本指令仅用于分离块的块头中。
- 本指令必须作为块头中最后一条指令，否则后序指令会被视为无效。
- DavinciOO v5 programmable SYS 是 coupled body，块体紧随 `BSTART.SYS`；SYS block 禁止使用 `B.TEXT`。

## Bit-level Encoding

### `B.TEXT` bit-level encoding

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:7]` | `simm25` | 25 | `` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `1` |
| `[0]` | `W` | 1 | `1` |
