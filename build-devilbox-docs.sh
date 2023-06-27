source dvl/bash/extras/ask.sh
source dvl/bash/extras/style.sh
source dvl/bash/extras/execute.sh

# Change directory
cd dvl/docs || exit

execute "make autobuild"
