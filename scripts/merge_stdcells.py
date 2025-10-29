import re
from pathlib import Path
import sys

def read_with_continuations(text: str) -> list[str]:
    lines = text.splitlines()
    merged, buf = [], ""
    for line in lines:
        if line.strip().startswith("*"):
            if buf:
                merged.append(buf); buf = ""
            merged.append(line); continue
        if line.startswith("+"):
            buf += " " + line.lstrip("+").strip()
        else:
            if buf:
                merged.append(buf)
            buf = line
    if buf:
        merged.append(buf)
    return merged

def collect_used_cells(design_lines: list[str]) -> set[str]:
    used = set()
    for ln in design_lines:
        s = ln.strip()
        if not s or s.startswith((".", "*")):
            continue
        if s[0].lower() == "x":
            tokens = [t for t in s.split() if "=" not in t]
            if len(tokens) >= 2:
                cell = tokens[-1]
                if cell.startswith("sg13g2_"):
                    used.add(cell)
    return used

def parse_library_subckts(lib_text: str) -> dict[str, list[str]]:
    subckts, name, buf = {}, None, []
    for raw in lib_text.splitlines():
        line = raw.rstrip("\n")
        m = re.match(r"^\s*\.subckt\s+(\S+)", line, flags=re.IGNORECASE)
        if m:
            if name:
                subckts[name] = buf[:]
            name, buf = m.group(1), [line]
            continue
        if name:
            buf.append(line)
            if re.match(r"^\s*\.ends(\b|\s|$)", line, flags=re.IGNORECASE):
                subckts[name] = buf[:]
                name, buf = None, []
    if name and buf:
        subckts[name] = buf[:]
    return subckts

def convert_x_to_m_inside_subckt(subckt_lines: list[str]) -> list[str]:
    out = []
    for line in subckt_lines:
        if line.strip().startswith((".", "*")):
            out.append(line); continue
        out.append(re.sub(r"^(\s*)[xX](\S*)", r"\1M\2", line))
    return out

def merge_spice_with_stdcell_defs(design_file: str, lib_file: str, out_file: str) -> dict:
    design_text = Path(design_file).read_text(errors="ignore")
    lib_text = Path(lib_file).read_text(errors="ignore")
    design_lines = read_with_continuations(design_text)
    used_cells = collect_used_cells(design_lines)
    lib_subckts = parse_library_subckts(lib_text)

    appended_blocks, missing = [], []
    for cell in sorted(used_cells):
        block = lib_subckts.get(cell)
        if not block:
            missing.append(cell); continue
        appended_blocks.append("\n".join(convert_x_to_m_inside_subckt(block)))

    header = [
        "* ---- BEGIN: inserted sg13g2 stdcell definitions (converted X* -> M*) ----",
        f"* Source library: {Path(lib_file).name}",
        f"* Total cells referenced in design: {len(used_cells)}",
        f"* Cells found and inserted: {len(appended_blocks)}",
    ]
    if missing:
        header.append(f"* Cells referenced but not found in library: {', '.join(sorted(missing))}")
    header.append("* ----------------------------------------------------------------------------")
    footer = "* ---- END: inserted sg13g2 stdcell definitions ----"

    merged = design_text.rstrip() + "\n\n" + "\n".join(header) + "\n\n" + "\n\n".join(appended_blocks) + "\n\n" + footer + "\n"
    Path(out_file).write_text(merged)

    return {
        "referenced_cells": sorted(used_cells),
        "inserted_cells": sorted([re.search(r'^\s*\.subckt\s+(\S+)', blk, flags=re.MULTILINE|re.IGNORECASE).group(1)
                                  for blk in appended_blocks]) if appended_blocks else [],
        "missing_cells": sorted(missing),
        "output_file": out_file,
    }

if __name__ == "__main__":

    spice_file = sys.argv[1]
    lib_file = sys.argv[2]
    output_file = sys.argv[3]

    # Example usage
    merge_spice_with_stdcell_defs(
        design_file=spice_file,
        lib_file=lib_file,
        out_file=output_file,
    )
