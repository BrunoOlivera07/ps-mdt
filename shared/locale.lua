local fallbackLocale = 'en-US'

local function lookup(locale, key)
    local value = MDTLocales and MDTLocales[locale]
    for part in key:gmatch('[^.]+') do
        if type(value) ~= 'table' then return nil end
        value = value[part]
    end
    return type(value) == 'string' and value or nil
end

function L(key, params)
    local locale = Config and Config.Locale or GetConvar('ps_mdt_locale', 'pt-BR')
    local value = lookup(locale, key) or lookup(fallbackLocale, key) or key
    if params then
        value = value:gsub('{([%w_]+)}', function(name)
            return params[name] ~= nil and tostring(params[name]) or ('{' .. name .. '}')
        end)
    end
    return value
end
