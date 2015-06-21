# ------------------------------------------------------------------------------
# COLOR DEFINITION
# ------------------------------------------------------------------------------

COLOR_NORMAL = \x1b[0m

COLOR_ATTR_NONE = \x1b[00;01m
COLOR_ATTR_BOLD = \x1b[01;01m
COLOR_ATTR_UNDERSCORE = \x1b[04;01m
COLOR_ATTR_BLINK = \x1b[05;01m
COLOR_ATTR_REVERSE = \x1b[07;01m
COLOR_ATTR_CONCEALED = \x1b[08;01m

COLOR_FG_BLACK = \x1b[30;01m
COLOR_FG_RED = \x1b[31;01m
COLOR_FG_GREEN = \x1b[32;01m
COLOR_FG_YELLOW = \x1b[33;01m
COLOR_FG_BLUE = \x1b[34;01m
COLOR_FG_MAGENTA = \x1b[35;01m
COLOR_FG_CYAN = \x1b[36;01m
COLOR_FG_WHITE = \x1b[37;01m

COLOR_BG_BLACK = \x1b[40;01m
COLOR_BG_RED = \x1b[41;01m
COLOR_BG_GREEN = \x1b[42;01m
COLOR_BG_YELLOW = \x1b[43;01m
COLOR_BG_BLUE = \x1b[44;01m
COLOR_BG_MAGENTA = \x1b[45;01m
COLOR_BG_CYAN = \x1b[46;01m
COLOR_BG_WHITE = \x1b[47;01m


# ------------------------------------------------------------------------------
# TASKS
# ------------------------------------------------------------------------------

install: configure_oh_my_zsh configure_eslint configure_git configure_vim

configure_oh_my_zsh:
	@echo ""
	@echo "$(COLOR_FG_GREEN)Configuring oh-my-zsh...$(COLOR_NORMAL)"

	@if [ -f ~/.zshrc ]; \
	then \
		echo "mv ~/.zshrc ~/.zshrc.bak"; \
		mv ~/.zshrc ~/.zshrc.bak; \
	fi;
	ln -sf $(PWD)/.zshrc ~/.zshrc

	@if [ ! -f ~/.zshrc.local ]; \
	then \
		touch ~/.zshrc.local; \
	fi;

configure_eslint:
	@echo ""
	@echo "$(COLOR_FG_GREEN)Configuring ESLint...$(COLOR_NORMAL)"

	@if [ -f ~/.eslintrc ]; \
	then \
		echo "mv ~/.eslintrc ~/.eslintrc.bak"; \
		mv ~/.eslintrc ~/.eslintrc.bak; \
	fi;
	ln -sf $(PWD)/.eslintrc ~/.eslintrc

configure_git:
	@echo ""
	@echo "$(COLOR_FG_GREEN)Configuring git...$(COLOR_NORMAL)"

	@if [ -f ~/.gitignore ]; \
	then \
		echo "mv ~/.gitignore ~/.gitignore.bak"; \
		mv ~/.gitignore ~/.gitignore.bak; \
	fi;
	@if [ -f ~/.gitconfig ]; \
	then \
		echo "mv ~/.gitconfig ~/.gitconfig.bak"; \
		mv ~/.gitconfig ~/.gitconfig.bak; \
	fi;

	ln -sf $(PWD)/.gitignore ~/.gitignore
	ln -sf $(PWD)/.gitconfig ~/.gitconfig

	@# Asks for git email
	@echo ""
	@echo "What is your $(COLOR_ATTR_BOLD)git e-mail$(COLOR_NORMAL)? $(COLOR_FG_BLACK)Eg. john.applessed@gmail.com$(COLOR_NORMAL)"; \
	read git_email; \
	sed_pattern="s/# email = {{git_email}}/  email = "$$git_email"/g"; \
	sed -i '' "$$sed_pattern" ~/.gitconfig

	@echo ""

	@# Asks for git name
	@echo "What is your $(COLOR_ATTR_BOLD)git name$(COLOR_NORMAL)? $(COLOR_FG_BLACK)Eg. John Appleseed$(COLOR_NORMAL)"; \
	read git_name; \
	sed_pattern="s/# name = {{git_name}}/  name = "$$git_name"/g"; \
	sed -i '' "$$sed_pattern" ~/.gitconfig

configure_vim:
	@echo ""
	@echo "$(COLOR_FG_GREEN)Configuring Vim...$(COLOR_NORMAL)"

	@if [ -f ~/.vimrc ]; \
	then \
		echo "mv ~/.vimrc ~/.vimrc.bak"; \
		mv ~/.vimrc ~/.vimrc.bak; \
	fi;
	ln -sf $(PWD)/.vimrc ~/.vimrc
