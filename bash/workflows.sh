# Load main shell scripts at workflows
source /etc/bashrc-devilbox.d/workflows/php-aliases.sh
source /etc/bashrc-devilbox.d/workflows/is-php-container-valid.sh
source /etc/bashrc-devilbox.d/workflows/node-aliases.sh

# Load PHP app shell scripts from workflows
source /etc/bashrc-devilbox.d/workflows/laravel/index.sh
source /etc/bashrc-devilbox.d/workflows/lumen/index.sh
source /etc/bashrc-devilbox.d/workflows/symfony/index.sh
source /etc/bashrc-devilbox.d/workflows/yii/index.sh

# Load Node app shell scripts from workflows
source /etc/bashrc-devilbox.d/workflows/astro/index.sh
source /etc/bashrc-devilbox.d/workflows/gatsby/index.sh
source /etc/bashrc-devilbox.d/workflows/next/index.sh
source /etc/bashrc-devilbox.d/workflows/vite/index.sh
