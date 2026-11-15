# fmt Package – Go Standard Library

## Overview

The `fmt` package implements formatted I/O with functions analogous to C's `printf` and `scanf`. Format verbs are derived from C but are simpler.

## Printing Verbs

### General
- `%v` – Default format
- `%+v` – Adds field names for structs
- `%#v` – Go-syntax representation
- `%T` – Type of value
- `%%` – Literal percent sign

### Boolean
- `%t` – `true` or `false`

### Integer
- `%b` – Binary
- `%c` – Unicode character
- `%d` – Decimal
- `%o` – Octal
- `%O` – Octal with `0o` prefix
- `%q` – Quoted character
- `%x` – Hexadecimal (lowercase)
- `%X` – Hexadecimal (uppercase)
- `%U` – Unicode format (`U+1234`)

### Floating-point & Complex
- `%b` – Scientific notation (base 2)
- `%e`, `%E` – Scientific notation
- `%f`, `%F` – Decimal
- `%g`, `%G` – Adaptive format
- `%x`, `%X` – Hexadecimal with exponent

### String & Byte Slice
- `%s` – Raw string
- `%q` – Quoted string
- `%x`, `%X` – Hexadecimal bytes

### Slice & Pointer
- `%p` – Address in hex (`0x` prefix)

## Formatting Rules

### Width & Precision
- `%9f` – Width 9
- `%.2f` – Precision 2
- `%9.2f` – Width 9, precision 2
- `%9.f` – Width 9, precision 0

Measured in **runes**, not bytes (except `%x`, `%X` for strings/slices).

### Flags
- `'+'` – Always print sign
- `'-'` – Left-justify
- `'#'` – Alternate format (e.g., `0x`, raw strings)
- `' '` – Space for sign
- `'0'` – Pad with zeros

## Special Behaviors

### Interfaces
If operand implements:
- `Formatter` → custom formatting
- `GoStringer` → used with `%#v`
- `error` → `Error()` method
- `String()` → used for string formatting

### Compound Types
Recursively formatted:
- Structs: `{field0 field1 ...}`
- Arrays/Slices: `[elem0 elem1 ...]`
- Maps: `map[key:value ...]`

## Explicit Argument Indexes

Use `[n]` before verb to format the nth argument:

```go
fmt.Sprintf("%[2]d %[1]d", 11, 22) // "22 11"
fmt.Sprintf("%[3]*.[2]*[1]f", 12.0, 2, 6) // " 12.00"
