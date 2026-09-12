local ShaderManager = {
    activeShaderId = "crt",
    compiledShaders = {},
    presets = {
        {
            id = "raw",
            name = "Pixel Puro (1:1)",
            tag = "Nativo",
            desc = "Renderização nativa pixel-perfect sem nenhum pós-processamento.",
            color = {0.4, 0.7, 1.0}
        },
        {
            id = "crt",
            name = "CRT Trinitron Scanlines",
            tag = "Tubo de Imagem",
            desc = "Simulação autêntica de TV analógica dos anos 90 com scanlines e fósforo.",
            color = {1.0, 0.45, 0.3}
        },
        {
            id = "lcd",
            name = "LCD Grid Authentic",
            tag = "Portátil",
            desc = "Grade de pixels visíveis característica das telas do Game Boy e GBA.",
            color = {0.15, 0.85, 0.55}
        },
        {
            id = "scale4x",
            name = "Scale4x / xBRZ HD",
            tag = "Alta Definição",
            desc = "Filtro de interpolação que arredonda curvas e suaviza serrilhados.",
            color = {0.75, 0.45, 1.0}
        },
        {
            id = "gba_color",
            name = "GBA Color Balance",
            tag = "Cores Vivas",
            desc = "Compensação de gama e saturação para corrigir jogos desenvolvidos para telas escuras.",
            color = {1.0, 0.8, 0.2}
        },
        {
            id = "vignette",
            name = "Retro Vignette & Glow",
            tag = "Atmosférico",
            desc = "Escurecimento sutil nos cantos da tela e leve aberração cromática retrô.",
            color = {0.9, 0.3, 0.6}
        }
    }
}

-- GLSL Shader for CRT Scanlines in Love2D
local CRT_SHADER_CODE = [[
extern number time;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    float scanline = sin(screen_coords.y * 1.8) * 0.07;
    pixel.rgb -= scanline;
    return pixel * color;
}
]]

-- GLSL Shader for LCD Grid in Love2D
local LCD_SHADER_CODE = [[
extern number time;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    float gridX = step(0.92, fract(screen_coords.x * 0.5)) * 0.05;
    float gridY = step(0.92, fract(screen_coords.y * 0.5)) * 0.05;
    pixel.rgb -= (gridX + gridY);
    return pixel * color;
}
]]

-- GLSL Shader for Vignette
local VIGNETTE_SHADER_CODE = [[
extern number time;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    vec2 uv = texture_coords - 0.5;
    float dist = dot(uv, uv);
    pixel.rgb *= (1.0 - dist * 0.45);
    return pixel * color;
}
]]

function ShaderManager.init(savedId)
    ShaderManager.activeShaderId = savedId or "crt"

    if love.graphics and love.graphics.newShader then
        local okCrt, sCrt = pcall(love.graphics.newShader, CRT_SHADER_CODE)
        if okCrt then ShaderManager.compiledShaders.crt = sCrt end

        local okLcd, sLcd = pcall(love.graphics.newShader, LCD_SHADER_CODE)
        if okLcd then ShaderManager.compiledShaders.lcd = sLcd end

        local okVig, sVig = pcall(love.graphics.newShader, VIGNETTE_SHADER_CODE)
        if okVig then ShaderManager.compiledShaders.vignette = sVig end
    end
end

function ShaderManager.getPresets()
    return ShaderManager.presets
end

function ShaderManager.setPreset(id)
    for _, p in ipairs(ShaderManager.presets) do
        if p.id == id then
            ShaderManager.activeShaderId = id
            return true
        end
    end
    return false
end

function ShaderManager.getActivePreset()
    for _, p in ipairs(ShaderManager.presets) do
        if p.id == ShaderManager.activeShaderId then
            return p
        end
    end
    return ShaderManager.presets[1]
end

function ShaderManager.getLoveShader()
    return ShaderManager.compiledShaders[ShaderManager.activeShaderId]
end

return ShaderManager
