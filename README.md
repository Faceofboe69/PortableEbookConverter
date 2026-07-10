# Portable Ebook Converter

A **no-install, portable Windows app** that converts HTML, AZW, MOBI, PDF, FB2, LIT,
TXT, DOCX and many other ebook/document formats to **EPUB** (or any other supported
output format). You can point it at a single file **or an entire folder** - and it
will optionally scan every nested sub-folder for convertible files.

It is a lightweight GUI wrapper around [Calibre's](https://calibre-ebook.com/)
battle-tested `ebook-convert` engine, so conversion quality matches Calibre itself.

## Why "no-install"?

The app itself is just a PowerShell script plus a `.cmd` launcher - nothing is
installed, no registry changes, no admin rights. PowerShell and .NET WinForms are
already built into every Windows 10/11 machine. You only need the Calibre
conversion engine available, which you can keep **portable** right next to the app.

## Files in this repo

| File | Purpose |
|------|---------|
| `Run-Converter.cmd` | Double-click this to launch the GUI. |
| `Convert-Ebooks.ps1` | The GUI application (WinForms). |
| `README.md` | This document. |

## One-time setup (get the portable engine)

1. Download the **Calibre Portable** build from the official site:
   https://calibre-ebook.com/download_portable
2. Extract it, and either:
   - copy its `Calibre` folder so that `ebook-convert.exe` ends up at
     `PortableEbookConverter\calibre\ebook-convert.exe`, **or**
   - just place `ebook-convert.exe` (and its DLLs) in a `calibre` sub-folder here.

If you already have Calibre installed normally, the app will find it automatically -
no copying required.

> The converter engine (Calibre) is downloaded by you directly from its official
> site. This project does not bundle or redistribute it.

## Using it

1. Double-click **`Run-Converter.cmd`**.
2. Click **Folder...** to pick a folder of ebooks, or **File...** for a single file.
3. Leave **"Include files in nested sub-folders (recursive)"** ticked to also convert
   files inside sub-folders.
4. Pick the target format under **Convert to** (EPUB is the default).
5. Choose where output goes - next to each source file, or a single output folder.
6. Click **Convert**. Progress and a per-file log are shown in the window.

## Supported formats

**Input (auto-detected when scanning):** epub, mobi, azw, azw3, azw4, html, htm,
htmlz, pdf, fb2, fbz, lit, lrf, odt, pdb, pml, rb, rtf, snb, tcr, txt, txtz, cbz,
cbr, docx.

**Output (selectable):** epub, mobi, azw3, pdf, fb2, html, htmlz, lit, lrf, pdb,
pml, rb, rtf, snb, tcr, txt, txtz, docx, oeb.

## Notes & tips

- PDF is a fixed-layout format; converting *from* PDF to a reflowable format like
  EPUB works best on text-based PDFs, not scanned images.
- Files already in the chosen output format are skipped automatically.
- Because the app just calls `ebook-convert`, any format Calibre supports will work
  even if it isn't listed above.

## Requirements

- Windows 10 or 11 (PowerShell 5.1 built-in, or PowerShell 7+).
- A copy of Calibre's `ebook-convert.exe` (portable or installed).
