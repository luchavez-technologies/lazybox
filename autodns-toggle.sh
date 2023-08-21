###
### Step 0: Declare functions
###

source dvl/bash/extras/ask.sh
source dvl/bash/extras/style.sh
source dvl/bash/extras/text-replace.sh
source dvl/bash/extras/execute.sh

###
### Step 2: Choose from workspaces
###

env="./dvl/.env"

default_dns_server='127.0.0.1'

default_bind_port='1053'
default_tld_suffix='traefik.me'

target_bind_port='53'
target_tld_suffix='test'

# Get current values
bind_port_variable="HOST_PORT_BIND="
bind_port=$(grep "^$bind_port_variable*" "$env")
bind_port_copy="$bind_port"
bind_port=${bind_port#$bind_port_variable}

tld_suffix_variable="TLD_SUFFIX="
tld_suffix=$(grep "^$tld_suffix_variable*" "$env")
tld_suffix_copy="$tld_suffix"
tld_suffix=${tld_suffix#$tld_suffix_variable}

if [ "$bind_port" == "$target_bind_port" ]; then
	autodns="ONLINE"
	todo="REMOVE"
	bind_port="$default_bind_port"
	tld_suffix="$default_tld_suffix"
else
	autodns="LOCAL"
	bind_port="$target_bind_port"
	tld_suffix="$target_tld_suffix"
	todo="ADD"
fi

# Ask user for confirmation
if ask_confirmation "Are you sure you want to turn on $(style " $autodns AUTO-DNS " bold bg-white)?"; then
	echo
	./stop.sh
    text_replace "^$bind_port_copy" "$bind_port_variable$bind_port" "$env"
    text_replace "^$tld_suffix_copy" "$tld_suffix_variable$tld_suffix" "$env"
    echo_todo "Please manually $(style " $todo $default_dns_server " bold bg-white) from DNS servers."
else
	echo
	echo_error "Failed to toggle auto-DNS."
fi
