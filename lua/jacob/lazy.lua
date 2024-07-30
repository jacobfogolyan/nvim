-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not (vim.uv or vim.loop).fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable", -- latest stable release
--     lazypath,
--   })
-- end
-- vim.opt.rtp:prepend(lazypath)
-- 
-- require("lazy").setup("jacob.plugins", {
--  install = { missing = true }
-- })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("jacob.plugins", {
    change_detection = {
        notify = false,
    },
    install = {
        -- Don't install missing plugins on startup
        missing = true,
    },
    checker = {
        enabled = true,
        -- Slow down plugin checks
        concurrency = 2,
        -- Check for updates every 48 hours
        frequency = 172800,
        -- Dont notify on neovim start
        notify = false,
    },
    git = {
        -- Show last 8 commits.
        log = {"-8"},
        -- kill clones that take more than 30 seconds.
        timeout = 30,
    },
    performance = {
        cache = {
            enabled = true,
        },
        rtp = {
            disabled_plugins = {
                "tutor",
                "tohtml",
                "gzip",
                "tarPlugin",
                "zipPlugin"
            },
        },
    },
})
