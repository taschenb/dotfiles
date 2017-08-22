#! /bin/sh
# Create symlinks to the dotfiles in this directory based on a specific set.
# Usage (install): ./bootstrap.sh <set>
# Usage (uninstall): ./bootstrap.sh uninstall

# Available sets:
# basic: Smallest setup to work with
set_basic="zshrc tmux.conf shell_prompt.sh aliases vim/vimrc"
# full: Typicall full workstation, not including any window manager
set_full="bashrc zshrc tmux.conf shell_prompt.sh aliases vim/vimrc \
config/nvim/init.vim latexmkrc git_template"
# git_template: Git templates to generate ctag files automatically
set_git_template="git_template"
# bspwm: WM settings
set_bspwm="config/bspwm/ config/sxhkd"
# awesome: WM settings
set_awesome="config/awesome/"

# Use the directory containing this script as absolute path for the symlinks
dotfile_dir=$(dirname $(readlink -f "$0"))
# Backup existing dotfiles to this directory before replacing them
backup_dir=~/.dotfiles_backup
# Track all symlinked files
installed_files="$backup_dir/.installed_files"
# Track all created directories
installed_dirs="$backup_dir/.installed_dirs"

usage() {
        printf "%s\n" "Usage (install): bootstrap.sh <set>"
        printf "%s\n\n" "Usage (uninstall): bootstrap.sh uninstall"
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
        exit 1
}

install () {
    set_to_install=$1

    if [ ! -d "$backup_dir" ]; then
        echo "Creating backup directory $backup_dir to store existing files"
        mkdir -p $backup_dir
    fi

    for file in $set_to_install; do
        echo "Processing ~/.$file"

        # If there is already a symlink there, delete it
        if [ -h "$HOME/.file" ]; then
            echo "Deleting old symlink"
            rm "$HOME/.$file"
        fi

        # If it is a file, back it up if not already done so
        if [ -f "$HOME/.$file" ] && [ -d $backup_dir ]; then
            echo "Backing up existing file"
            mv -i "$HOME/.$file" "$backup_dir/"
        fi

        # Create the directory the symlink is going to be in
        directory=$(dirname "$HOME/.$file")
        if [ ! -d "$directory" ] ; then
            echo "Creating missing directory $directory"
            mkdir -p "$directory"
            echo "$directory" >> "$installed_dirs"
        fi

        echo "Creating symlink"
        ln -s "$dotfile_dir/$file" "$HOME/.$file"
        echo "$HOME/.$file" >> "$installed_files"
        echo ""
    done
}

uninstall() {
    # Remove all created symlinks and put any backuped files back
    if [ -f "$installed_files" ]; then
        while read -r line; do
            file="$line"
            if [ -h "$file" ]; then
                echo "Remove symlink $file..."
                rm "$file"
            fi
            if [ -f "$backup_dir/$file" ]; then
            echo "Found backup of $file. Put it back..."
            mv -i "$backup_dir/$file" "$file"
            fi
        done < "$installed_files"

        rm $installed_files
    fi

    # Finally, remove created directories
    if [ -f $installed_dirs ]; then
        while read -r line; do
            dir="$line"
            if [ -d "$dir" ]; then
                echo "Removing previously created directory $dir"
                if [ "$(find "$dir" | wc -l)" -gt 0 ]; then
                    echo "WARNING: DIRECTORY IS NOT EMPTY"
                fi
                rm -ri "$dir"
            fi
        done < "$installed_dirs"

        rm $installed_dirs
    fi

    # Cleanup the backup_dir itself
    if [ "$(find "$backup_dir" | wc -l)" -gt 0 ]; then
        echo "Seems you have still files in $backup_dir..."
        echo "Review and delete manually"
    else
        echo "Removing $backup_dir..."
        rm -r "$backup_dir"
    fi
}

case "$1" in
    full)
        install "$set_full"
        git config --global init.templatedir "$HOME/.git_template"
        ;;
    basic)
        install "$set_basic";;
    git_template)
        install "$set_git_template"
        git config --global init.templatedir "$HOME/.git_template"
        ;;
    bspwm)
        install "$set_bspwm";;
    awesome)
        install "$set_awesome";;
    uninstall)
        uninstall;;
    *)
        usage;;
esac
