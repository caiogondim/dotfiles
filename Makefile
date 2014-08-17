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

install: exit_if_not_osx configure_git configure_vim

install_homebrew:
	@echo ""
	@echo "$(COLOR_FG_GREEN)Installing homebrew...$(COLOR_NORMAL)"
	@homebrew_script=`curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install`; \
	`ruby -e $$homebrew_script`

configure_git:
	@echo ""
	@echo "$(COLOR_FG_GREEN)Installing git files...$(COLOR_NORMAL)"

	@# Moves git files to ~
	@cp .gitignore ~/.gitignore
	@cp .gitconfig ~/.gitconfig

	@# Asks for git email
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

exit_if_not_osx:
ifneq ($(shell uname -s),Darwin)
	@echo "$(COLOR_FG_RED)That install script supports only OS X$(COLOR_FG_NORMAL)"
	@exit 1
endif

configure_vim:
	@echo ""
	@echo "$(COLOR_FG_GREEN)Configuring Vim...$(COLOR_NORMAL)"

	@cp .vimrc ~/.vimrc
