-- svg-to-pdf.lua
-- Pandoc Lua-Filter: Ersetzt SVGs durch PDFs für LaTeX-Ausgabe

function Image(el)
    -- Prüfe: nur für LaTeX-Output
    if FORMAT:match("latex") then
      -- Nur SVG-Dateien
      if el.src:match("%.svg$") then
        -- Ersetze Endung .svg durch .pdf
        el.src = el.src:gsub("%.svg$", ".pdf")
      end
    end
    return el
  end