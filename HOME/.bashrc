# ~/.bashrc: executed by bash(1) for non-login shells.
#
# This file is executed for each subshell opened by bash.
# For some variables and initialization that is not bash-specific or that is
# intended to be executed only once, see ~/.profile
#
# Also see /usr/share/doc/bash/examples/startup-files (installing bash-doc)
# for other bashrc examples
#
# Fernando Carmona Varo <ferkiwi@gmail.com>
#

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# List of commands to ignore ("&" means ignore duplicates)
export HISTIGNORE="&:?:??:exit:history"

# Add timestamps to history file
export HISTTIMEFORMAT="%F %T "

export HISTSIZE=100000

OS=$(uname -s)

if [ "$OS" = "Darwin" ]
then
    # Load completion from brew
    . "$(brew --prefix)/etc/bash_completion"
else
   shopt -s checkjobs # needs to double close if there are pending jobs
   shopt -s globstar # recursive globbing with **
   shopt -s cdspell dirspell # spelling corrections when cd'ing and globbing
fi

shopt -s checkwinsize # refresh LINES and COLUMNS when window size changes
shopt -s no_empty_cmd_completion # dont autocomplete on empty lines

# Color! ...if the terminal where this subshell is running supports it
[ "$TERM" != "dumb" ] && {

    # set LS variable for ls filename colorization (see ~/.dir_colors)
    hash dircolors 2>&- && eval "$(dircolors -b ~/.dir_colors)"

    # Colorize (red) the stderr output in the terminal
    [ -f "/usr/lib/stderred.so" ] && export LD_PRELOAD="/usr/\$LIB/stderred.so"


### Formatting escape codes
## *0-*8 attributes ( 00-08:set 20-28:reset )
# 0:none 1:bold 2:dim 3:italic 4:underline 5-6:blink 7:invert 8:hidden
## 256 colors ( 38;5;0-256:fg 48;5;0-256:bg )
# Run 256-colors.sh script
## *0-*7 colors ( 30-27:darkFg 40-47:darkBg 90-97:lightFg 100-107:darkBg )
# 0:black 1:red 2:green 3:yellow 4:blue 5:purple 6:cyan 7:white 8:default

    ###
    # Fancy Prompt

    # Different color according to error value
    PSCOLOR='eval [[ $? = 0 ]] && { [[ $EUID = 0  ]] && echo -ne "\033[1;36m" || echo -ne "\033[32m"; } || echo -ne "\033[31m";'
    PS1='\[\033[33m\]\t \[$($PSCOLOR)\]\u\[\033[0m\]:\[\033[94m\]${sPWD:-${PWD/$HOME/~}}\[\033[0m\]\$ '

    [ "$DISPLAY" ] && {

	__on_debug() { 	    
            # Show current running command in window title (only printf allows proper sanitization)
	    printf "\e]2;%s\a" "${BASH_COMMAND/\\/\\\\}"; 

	    # Update history after each command (good in case of a crash)
	    history -a # ; history -n
	}
	trap __on_debug DEBUG

	__before_prompt_hook() {
	    # # Print a newline if not in the first column
	    # firstcolumn
	    # Do a backspace followed by a newline, this way we can
	    # be sure that the prompt is in the first column.
	    #tput bw && echo -ne "\b\n" # Only works in terminals with "bw" capability
	    
            # When the running program ended, show this title instead
	    echo -ne "\e]2;${PWD/$HOME/~} - ${TERM}@${HOSTNAME}\a"

	    # if the full path is too long, use shorter one
	    if [ $(pwd | wc -m) -gt $((COLUMNS/2)) ]; then
		sPWD="../${PWD##*/}"
	    else
		sPWD="${PWD/$HOME/~}"
	    fi
	}

	if  ! (( "${BASH_VERSION%%.*}" < "4" ))
	then
	    PROMPT_COMMAND=__before_prompt_hook
	fi

	# __on_resize() {
	# }
	# trap __on_resize SIGWINCH
	# __on_resize

       # # set iconname
       # echo -ne "\e]1;gnome-terminal\a"
    }

    # If unknown terminal, set as linux console
    tset 2>&1 >/dev/null || export TERM=linux 
}

# Source additional custom completion and aliases files
#[[ -f ~/.bash_completion ]] && . ~/.bash_completion
#[[ -d ~/.bash_completion.d ]] && . ~/.bash_completion.d/*
[[ -f ~/.sh_aliases ]] && . ~/.sh_aliases
[[ -f ~/.bash_aliases ]] && . ~/.bash_aliases

# Show Version Control status after cd'ing to a versioned directory
cd() {
    [ -z "$1" ] && builtin cd && return $?
    builtin cd "$1" "$2" && {
	git rev-parse --git-dir 2>&- >&- && {
	    git status -bs --untracked-files="no" #| column -c $COLUMNS
	    git log -3 --pretty=format:'%an, %ar: %s' | cut -c -$COLUMNS
	}
    }
}


hash fasd 2>&- && eval "$(fasd --init auto)"


###
# display login messages (if it's a real terminal)
[ "$TERM" != "dumb" ] && {
    echo -e "\033[36m $(uptime)"
    last -3 | head -n -2
    echo -e '\033[33m'
    hash fortune 2>&- && fortune -cs
    echo -e '\033[00m'
}

[ -d $HOME/Source/ToolChain_STM32/ToolChain ] && {
    source $HOME/Source/ToolChain_STM32/ToolChain/scripts/SourceMe.sh
}

export PERL_LOCAL_LIB_ROOT="$HOME/perl5";
export PERL_MB_OPT="--install_base $HOME/perl5";
export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5";
export PERL5LIB="$HOME/perl5/lib/perl5/i686-linux-thread-multi:$HOME/perl5/lib/perl5";
export PATH="$HOME/perl5/bin:$PATH";
