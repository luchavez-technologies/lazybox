source /etc/bashrc-devilbox.d/extras/style.sh
source /etc/bashrc-devilbox.d/extras/own.sh
source /etc/bashrc-devilbox.d/workflows/node-aliases.sh

# Needed by Symfony
own_directory /var/cache
own_directory /var/log
own_directory /var/lib

# Own NVM automatically by devilbox user
own_nvm

# The loaded ".env" file cannot be edited using "sed" function.
# It was found out that overriding the contents via "cat" function works.
# Therefore, we just save a copy of ".env" to "/tmp" then override the original's contents.
own_file /.env
