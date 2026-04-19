-- Debug script to check LSP status for Vue files
-- Run this with :luafile % when you have a Vue file open

local function check_lsp_status()
    print("=== LSP Status for Current Buffer ===")
    
    -- Current buffer info
    local bufnr = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[bufnr].filetype
    local filename = vim.api.nvim_buf_get_name(bufnr)
    
    print("Buffer: " .. bufnr)
    print("File: " .. filename)
    print("Filetype: " .. filetype)
    print("")
    
    -- Get attached LSP clients
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    
    if #clients == 0 then
        print("❌ No LSP clients attached to this buffer!")
        print("")
        print("Possible reasons:")
        print("1. LSP server not installed (check :Mason)")
        print("2. Root directory not detected")
        print("3. Filetype not configured for any LSP server")
        return
    end
    
    print("✅ Active LSP clients (" .. #clients .. "):")
    print("")
    
    for _, client in ipairs(clients) do
        print("Client: " .. client.name)
        print("  ID: " .. client.id)
        print("  Root: " .. (client.config.root_dir or "none"))
        
        -- Check if hover is supported
        if client.server_capabilities then
            local hover_supported = client.server_capabilities.hoverProvider
            if hover_supported then
                print("  ✅ Hover: SUPPORTED")
            else
                print("  ❌ Hover: NOT SUPPORTED")
            end
            
            -- Check other capabilities
            local caps = client.server_capabilities
            print("  Other capabilities:")
            print("    Definition: " .. tostring(caps.definitionProvider ~= nil))
            print("    TypeDefinition: " .. tostring(caps.typeDefinitionProvider ~= nil))
            print("    References: " .. tostring(caps.referencesProvider ~= nil))
            print("    Completion: " .. tostring(caps.completionProvider ~= nil))
        else
            print("  ⚠️  No server capabilities reported")
        end
        print("")
    end
    
    -- Check keybinding
    print("=== Keybinding Check ===")
    local keymap = vim.api.nvim_buf_get_keymap(bufnr, 'n')
    local found_K = false
    for _, mapping in ipairs(keymap) do
        if mapping.lhs == "K" then
            found_K = true
            print("K is mapped to: " .. (mapping.rhs or mapping.callback or "unknown"))
            break
        end
    end
    
    if not found_K then
        print("❌ K is not mapped in this buffer!")
    end
end

check_lsp_status()