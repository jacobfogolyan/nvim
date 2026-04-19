-- Enhanced debug script for hover functionality
-- Run this with :luafile % when you have a Vue file open

local function debug_hover()
    print("=== Enhanced Hover Debug ===\n")
    
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
    
    print("Buffer #" .. bufnr .. " - " .. vim.api.nvim_buf_get_name(bufnr))
    print("Filetype: " .. vim.bo[bufnr].filetype)
    print("")
    
    if #clients == 0 then
        print("❌ No LSP clients attached!")
        return
    end
    
    print("LSP Clients (" .. #clients .. "):")
    for _, client in ipairs(clients) do
        print("\n📦 " .. client.name .. " (ID: " .. client.id .. ")")
        
        -- Check hover capability
        local hover = client.server_capabilities.hoverProvider
        if hover then
            print("  ✅ Hover: ENABLED")
        else
            print("  ❌ Hover: DISABLED")
        end
        
        -- Check resolved capabilities
        if client.resolved_capabilities then
            print("  Legacy hover: " .. tostring(client.resolved_capabilities.hover))
        end
    end
    
    print("\n=== Testing Hover Function ===")
    print("Attempting to trigger hover...")
    
    -- Try to manually trigger hover
    local params = vim.lsp.util.make_position_params()
    local results = {}
    
    for _, client in ipairs(clients) do
        if client.server_capabilities.hoverProvider then
            print("\nRequesting hover from " .. client.name .. "...")
            
            client.request("textDocument/hover", params, function(err, result)
                if err then
                    print("  ❌ Error: " .. vim.inspect(err))
                elseif result and result.contents then
                    print("  ✅ Got hover response!")
                    -- Try to display it
                    vim.lsp.handlers["textDocument/hover"](err, result, { client_id = client.id })
                else
                    print("  ⚠️  No hover information at cursor position")
                end
            end, bufnr)
        end
    end
    
    print("\n=== Keybinding Check ===")
    local keymaps = vim.api.nvim_buf_get_keymap(bufnr, 'n')
    for _, km in ipairs(keymaps) do
        if km.lhs == "K" then
            print("K is mapped to: " .. (km.rhs or km.desc or "function"))
            if km.desc then
                print("  Description: " .. km.desc)
            end
            break
        end
    end
    
    print("\n=== Manual Hover Test ===")
    print("Try running: :lua vim.lsp.buf.hover()")
    print("This should show the same hover window as pressing K")
end

-- Also provide a simple test function
function TestHover()
    vim.lsp.buf.hover()
end

debug_hover()

print("\n💡 You can also run :lua TestHover() to test hover directly")