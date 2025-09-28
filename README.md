# Complex Number Divider

**Authors**  
- Francisco Bessa L. Câmara — up202006727  
- Francisco G. Vilarinho — up202005500  


## Overview

This project implements hardware modules in Verilog to **divide complex numbers**:

(a + jb) ÷ (c + jd) = (a c + b d + j(b c – a d)) / (c² + d²)

Different architectures are explored to balance **latency, area, and resource sharing**.


## Files

| File | Description |
|------|-------------|
| `cpxdiv1.v` | 1 combinational multiplier + 2 sequential dividers |
| `cpxdiv2.v` | 1 combinational multiplier + 1 sequential divider |
| `cpxdiv3.v` | 2 sequential multipliers + 2 sequential dividers (final version) |
| `cpxdiv_tb.v` | Professor’s testbench with full stimuli |
| `cpxdiv_tbmine.v` | Custom, simpler testbench for debugging |
| `doc/` | Project report and design notes (PDFs) |

## Results

* cpxdiv1: simpler, higher latency

* cpxdiv2: more resource sharing

* cpxdiv3: balanced design (used in report)
