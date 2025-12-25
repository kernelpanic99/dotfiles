# Just another neovim config

> [!IMPORTANT]
> This is my personal, highly opinionated config. If you are looking for something to plug and play - move on.

## Features/Antifeatures

- **Single file:** everything is organized with folds. The best way to write configs IMO.
- **Bootstrapped:** the config will make the best effort to install everything it needs, or at least tell what's missing.
- **Heavy external tool reliance:** lazygit, yazi, fzf, claude etc. See `executables` in "Check executables" section for full list
- **Modern treesitter:** recent treesitter rewrite blew up many configs. This one is written from scratch with new treesitter in mind. Many plugins relying on treesitter may not work though. The one I wasn't able to get working is neorg. It's probably possible but I didn't care about it enough.
- **Register behavior:** I'm using cutlass.nvim to prevent all operators but `y` and `d` from putting the result into default register. `d` is unusual for "cut", but it makes sense to me. Also use `<leader><op>` to put into system clipboard.
- Blink.cmp is using rust version of the matcher which is faster, but requires nightly rust on the system (hence `cargo +nightly` requirement). Put `fuzzy = { implementation = "lua" }` into `opts` and remove `cargo +nightly` from `executables` if you don't want that.
- **AI integration:** Claude code integration via `coder/claudecode.nvim`, this may not be the best option, but this is what I have at the moment.
