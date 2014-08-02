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
install:
	@echo "$(COLOR_ATTR_REVERSE)Ipsum$(COLOR_NORMAL) lorem"
