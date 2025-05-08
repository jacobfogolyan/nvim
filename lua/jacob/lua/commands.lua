vim.api.nvim_create_user_command('AllEntities', function()
    local files = vim.fn.systemlist('find . -name "*.entity*" -not -path "*/dist/*"')
    vim.cmd('args ' .. table.concat(files, ' '))
end, {})
