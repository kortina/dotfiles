#!/usr/bin/env bash
set -e

DOTFILES_ROOT="`pwd`"
BACKUP_DIR="${HOME}/old_dotfiles/`date +%Y-%m-%d.%H:%M:%S`"


function link_file {
	source=$1
	# strip the .symlink and everything after
	lnk=`basename $source | sed 's/\.symlink.*//g'`
	# prepend a "." 
	lnk="$HOME/.$lnk"
	
	if [ -h $lnk ]
	then
		old_source=`readlink $lnk`
		if [ "$old_source" != "$source" ]
		then
			rm $lnk
			echo "WARN: removed legacy symlink: $lnk -> $old_source"
		fi
	else
		if [ -f $lnk ] || [ -d $lnk ]
		then
			if [ ! -d $BACKUP_DIR ]
			then
				mkdir -p $BACKUP_DIR
				echo "WARN: made backup directory $BACKUP_DIR"
			fi
			echo "WARN: moved old $lnk to $BACKUP_DIR"
			mv $lnk $BACKUP_DIR/
		fi
	fi
	
	if [ ! -h $lnk ]
	then
		ln -s $source $lnk && echo "Created $lnk -> $source"
	fi

}

for source in `find $DOTFILES_ROOT -name \*.symlink\*`
do
	link_file $source
done

# other directories and things to link
link_file "$DOTFILES_ROOT/vim"

echo "dotfiles installed"

