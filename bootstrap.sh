#! /bin/sh

# Create symlinks to the dotfiles in this directory based on a specific set.
# Usage: ./bootstrap.sh <set>


# Sets:

# Smallest setup to work with
set_basic="zshrc tmux.conf shell_prompt.sh aliases vim/vimrc"

# Typicall full workstation, not including any window manager
set_full="bashrc zshrc tmux.conf shell_prompt.sh aliases vim/vimrc \
config/nvim/init.vim latexmkrc git_template"

# Git templates to generate ctag files automatically
set_git_template="git_template"

# WM
set_bspwm="config/bspwm/ config/sxhkd"
set_awesome="config/awesome/"


# Use the directory containing this script as absolute path for the symlinks
dotfile_dir=$(dirname $(readlink -f "$0"))
# Backup existing dotfiles to this directory before replacing them
backup_dir=~/.dotfiles_backup


case "$1" in
    full)
        install=$set_full
        git config --global init.templatedir "$HOME/git_template"
        ;;
    basic)
        install=$set_basic;;
    git_template)
        install=$set_git_template
        git config --global init.templatedir "$HOME/.git_template"
        ;;
    bspwm)
        install=$set_bspwm;;
    awesome)
        install=$set_awesome;;
    *)
        printf "%s\n" "Usage:bootstrap.sh <set>"
        printf "%s\n%s\n %s\n%s\n %s\n%s\n %s\n%s\n %s\n%s\n %s\n" \
               "Available sets:" \
               "full:" \
               "$set_full" \
               "basic:" \
               "$set_basic" \
               "git_template:" \
               "Setup git templates for ctags" \
               "bspwm" \
               "Setup bspwm and lembonar-xft" \
               "awesome" \
               "Setup awesome"
        exit 1;;
esac


if [ ! -d "$backup_dir" ]; then
    echo "Creating backup directory $backup_dir to store existing files"
    mkdir -p $backup_dir
fi


for file in $install; do
    echo "Processing ~/.$file"

    # If there is already a symlink there, delete it
    if [ -h ~/.$file ]; then
        echo "Deleting old symlink"
        rm ~/.$file
    fi

    # If it is a file, back it up if not already done so
    if [ -f ~/.$file ] && [ -d $backup_dir ]; then
        echo "Backing up existing file"
        mv -i ~/.$file $backup_dir/
    fi

    # Create the directory the symlink is going to be in
    directory=$(dirname ~/.$file)
    if [ ! -d $directory ] ; then
        echo "Creating missing directory $directory"
        mkdir -p $directory
    fi

    echo "Creating symlink"
    ln -s $dotfile_dir/$file ~/.$file
    echo ""
done
