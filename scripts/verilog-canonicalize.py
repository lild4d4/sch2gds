#!/usr/bin/env python3
import sys
import re

def split_top_level_commas(s: str) -> list[str]:
    parts, buf, depth = [], [], 0
    i = 0
    while i < len(s):
        ch = s[i]
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth = max(0, depth - 1)
        elif ch == ',' and depth == 0:
            parts.append(''.join(buf).strip())
            buf = []
            i += 1
            continue
        buf.append(ch)
        i += 1
    tail = ''.join(buf).strip()
    if tail:
        parts.append(tail)
    return parts

def contains_pin(entry: str, pin_names: set[str]) -> bool:
    for p in pin_names:
        if re.search(rf'\b{re.escape(p)}\b', entry):
            return True
    return False

def rebuild_block(block_text: str, pin_names: set[str]) -> str:
    first_par = block_text.find('(')
    last_close = block_text.rfind(')')
    if first_par == -1 or last_close == -1 or last_close < first_par:
        return block_text

    header = block_text[:first_par].rstrip()
    inside = block_text[first_par + 1:last_close]
    tail = block_text[last_close + 1:]

    indent_match = re.search(r'\n([ \t]+)\S', inside)
    indent = indent_match.group(1) if indent_match else "  "

    entries = split_top_level_commas(inside)
    kept = [e for e in (x for x in entries if x) if not contains_pin(e, pin_names)]

    if not kept:
        new_inside = ""
    else:
        if len(kept) == 1:
            new_inside = f"\n{indent}{kept[0].strip()}\n"
        else:
            lines = [f"{indent}{e.strip()}," for e in kept[:-1]]
            lines.append(f"{indent}{kept[-1].strip()}")
            new_inside = "\n" + "\n".join(lines) + "\n"

    return f"{header}({new_inside}){tail}"

def main():
    if len(sys.argv) != 5:
        print("Usage: script.py <input.v> <output.v> <POWER_PIN> <GROUND_PIN>")
        sys.exit(2)

    in_path, out_path, power_pin, ground_pin = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
    pin_names = {power_pin, ground_pin}

    with open(in_path, "r") as fin:
        src = fin.read()

    out = []
    i = 0
    n = len(src)

    pending_cell_header = None  # holds a line starting with sg13g2_ awaiting its instance block

    def flush_pending_header(write_attr: bool):
        nonlocal pending_cell_header
        if pending_cell_header is not None:
            if write_attr:
                out.append('(* keep *)(* dont_touch = "true" *)\n')
            out.append(pending_cell_header)
            pending_cell_header = None

    while i < n:
        line_start = i
        j = src.find("\n", i)
        if j == -1:
            j = n
        line = src[line_start:j]

        stripped = line.lstrip()

        # Capture header-only line like "sg13g2_mux2_2"
        if stripped.startswith("sg13g2_") and "(" not in line:
            # Do not write yet; remember it and wait for the following instance block
            pending_cell_header = line + ("\n" if j < n else "")
            i = j + (1 if j < n else 0)
            continue

        # Lines that mention power/ground but are not part of a parenthesis block: skip
        if (re.search(rf'\b{re.escape(power_pin)}\b', line) or re.search(rf'\b{re.escape(ground_pin)}\b', line)) and "(" not in line:
            i = j + (1 if j < n else 0)
            continue

        # If this line starts or contains a parenthesis block, consume until ';' at top level and rebuild
        if "(" in line:
            block_start = line_start
            paren_depth = 0
            k = line_start
            reached = False
            while k < n:
                ch = src[k]
                if ch == '(':
                    paren_depth += 1
                elif ch == ')':
                    paren_depth = max(0, paren_depth - 1)
                if ch == ';' and paren_depth == 0:
                    k += 1
                    reached = True
                    break
                k += 1

            if not reached:
                # Not a normal block; if we had a pending header, flush it without attr and write line
                flush_pending_header(write_attr=True)  # best effort
                out.append(line + ("\n" if j < n else ""))
                i = j + (1 if j < n else 0)
                continue

            block_text = src[block_start:k]

            # If we have a pending header (previous line was sg13g2_*), emit attribute + header before block
            if pending_cell_header is not None:
                flush_pending_header(write_attr=True)
            else:
                # If NO pending header, still check if this very line is an sg13g2_ instance on one line (rare but possible)
                if stripped.startswith("sg13g2_"):
                    out.append('(* keep *)(* dont_touch = "true" *)\n')

            rebuilt = rebuild_block(block_text, pin_names)
            out.append(rebuilt)
            i = k
            continue

        # Normal line: before writing, if there is a pending header but the next thing is not an instance block,
        # flush it (with attribute), then write this line.
        if pending_cell_header is not None:
            flush_pending_header(write_attr=True)

        out.append(line + ("\n" if j < n else ""))
        i = j + (1 if j < n else 0)

    # EOF: flush any pending header (with attribute)
    if pending_cell_header is not None:
        flush_pending_header(write_attr=True)

    with open(out_path, "w") as fout:
        fout.write("".join(out))

if __name__ == "__main__":
    main()
