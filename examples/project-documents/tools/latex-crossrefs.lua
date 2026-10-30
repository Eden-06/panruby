-- latex-crossrefs.lua
-- Lua filter for Pandoc to convert Markdown links with labels {#...} to LaTeX \ref{}
-- Only for LaTeX output

function Link(el)
    -- Prüfen, ob die Link-Attribute ein Label in geschweiften Klammern haben
    local id = el.attributes["id"]
    if not id then
        -- Pandoc speichert Markdown-Label {#xyz} manchmal direkt in el.identifier
        id = el.identifier
    end

    if id and #id > 0 then
        -- Label gefunden, in \ref umwandeln
        return pandoc.RawInline('tex', '\\ref{' .. id .. '}')
    end

    -- sonst nichts ändern
    return el
end