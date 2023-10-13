---
layout: default
title: "Vim Setup"
---
A very easy setup for [Neovim](https://neovim.io/).
Note: This setup will come with LSPs for c, cpp, and lua. For more, you will need to configure on your own.

## Why?
1. Speed: You will edit text fast.
2. Understanding: You will learn how text editors (and IDEs) work.
3. Efficiency: Startup time will be measured in milliseconds.
4. Universal: Almost all machines (you come across) will have vim installed.

## Installing Neovim
If you are working on ugrad machines, you can skip this step as Neovim is already installed.

NvChad requires version >= 0.9.0  
Follow instruction [here](https://github.com/neovim/neovim/wiki/Installing-Neovim)

## Setting up [NvChad](https://nvchad.com/)
1. Your terminal is required to use a [Nerd Font](https://www.nerdfonts.com/). If you can't make up your mind, use `JetbrainsMono Nerd Font`
2. run `git clone https://github.com/ishme-al/csf-vim ~/.config/nvim --depth 1 && nvim`

## Post-Install (optional)
1. Install [ripgrep](https://github.com/BurntSushi/ripgrep) for additional functionality
2. in your `~/.bashrc`

	```bash
	alias vim='nvim'
	```

3. If you prefer spaces instead of tabs, in `~/.config/nvim/lua/custom/init.lua` delete this line

	```vim
	vim.opt.expandtab=false
	```


4. If you prefer 2 spaces for a tab, delete the file.

## Learning Neovim
1. vim motions: `vimtutor` in ugrad will bring up a tutorial
2. `<space> + ch` in Neovim will bring up a cheatsheet (`<leader>` is by default mapped to the space key)

## Issues?
Any set of these instructions may break. If you do face any issues (or just want to talk about vim) let me know at [imeal1@jh.edu](mailto:imeal1@jh.edu)
* Colors may be broken. `:checkhealth` in Neovim to see if there are any issues. Any decent terminal emulator should support proper colors (iTerm2, Windows Terminal)
* Clipboard may not work

## Future Steps (for you)
* Learn Lua (used to configure Neovim)
* Learn how to configure NvChad
* Ditch NvChad! Configure everything yourself.
* Learn Tmux
* Learn Emacs?
