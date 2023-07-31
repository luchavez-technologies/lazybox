# Test PHP workflows
function test_php_workflows() {
	local args=""

	for arg in "$@"; do
		if [ "$arg" = "-n" ] || [ "$arg" = "--no-interaction" ]; then
			args="&>/dev/null"
		fi
	done

	local tests=(
		"test_laravel_new_workflow"
		"test_laravel_clone_workflow"
		"test_lumen_new_workflow"
		"test_lumen_clone_workflow"
		"test_yii_new_workflow"
		"test_yii_clone_workflow"
		#"test_symfony_new_workflow" #TODO: Symfony Create New App
		#"test_symfony_clone_workflow" #TODO: Symfony Clone App
	)

	# iterate over the tests array
	for test in "${tests[@]}"; do
		execute "$test $args"
	done
}

# Test NodeJS workflows
function test_node_workflows() {
	local args=""

	for arg in "$@"; do
		if [ "$arg" = "-n" ] || [ "$arg" = "--no-interaction" ]; then
			args="&>/dev/null"
		fi
	done

	local tests=(
		#"test_next_new_workflow"
		#"test_next_clone_workflow"
		#"test_astro_new_workflow"
		#"test_astro_clone_workflow"
		#"test_gatsby_new_workflow"
		#"test_gatsby_clone_workflow"
		#"test_vite_clone_workflow" # starts first since there are too many Vite templates
		"test_vite_vanilla_new_workflow"
		"test_vite_vanilla_ts_new_workflow"
		"test_vite_vue_new_workflow"
		"test_vite_vue_ts_new_workflow"
		"test_vite_react_new_workflow"
		"test_vite_react_ts_new_workflow"
		"test_vite_react_swc_new_workflow"
		"test_vite_react_swc_ts_new_workflow"
		"test_vite_preact_new_workflow"
		"test_vite_preact_ts_new_workflow"
		"test_vite_lit_new_workflow"
		"test_vite_lit_ts_new_workflow"
		"test_vite_svelte_new_workflow"
		"test_vite_svelte_ts_new_workflow"
		"test_vite_solid_new_workflow"
		"test_vite_solid_ts_new_workflow"
		"test_vite_qwik_new_workflow"
		"test_vite_qwik_ts_new_workflow"
	)

	# iterate over the tests array
	for test in "${tests[@]}"; do
		execute "$test $args"
	done
}

# PHP WORKFLOWS

# Test Laravel New Workflow
function test_laravel_new_workflow() {
	local framework_version="10"
	local name="laravel-new-$RANDOM"
	local php_version
	local node_version

	php_version=$(php_version)
	node_version=$(node_version)

	echo_ongoing "Testing Laravel New Workflow"
	execute "laravel_new $name $framework_version $php_version $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Laravel New Workflow
function test_laravel_clone_workflow() {
	local url="https://github.com/lazybox-examples/laravel-10-test.git"
	local branch="develop"
	local name="laravel-clone-$RANDOM"
	local php_version
	local node_version

	php_version=$(php_version)
	node_version=$(node_version)

	echo_ongoing "Testing Laravel Clone Workflow"
	execute "laravel_clone $url $branch $name $php_version $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Lumen New Workflow
function test_lumen_new_workflow() {
	local framework_version="10"
	local name="lumen-new-$RANDOM"
	local php_version
	local node_version

	php_version=$(php_version)
	node_version=$(node_version)

	echo_ongoing "Testing Lumen New Workflow"
	execute "lumen_new $name $framework_version $php_version $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Lumen New Workflow
function test_lumen_clone_workflow() {
	local url="https://github.com/lazybox-examples/lumen-10-test.git"
	local branch="develop"
	local name="lumen-clone-$RANDOM"
	local php_version
	local node_version

	php_version=$(php_version)
	node_version=$(node_version)

	echo_ongoing "Testing Lumen Clone Workflow"
	execute "lumen_clone $url $branch $name $php_version $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Yii New Workflow
function test_yii_new_workflow() {
	local name="yii-new-$RANDOM"
	local php_version

	php_version=$(php_version)

	echo_ongoing "Testing Yii New Workflow"
	execute "yii_new $name $php_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Yii New Workflow
function test_yii_clone_workflow() {
	local url="https://github.com/lazybox-examples/yii-test.git"
	local branch="develop"
	local name="yii-clone-$RANDOM"
	local php_version
	local node_version

	php_version=$(php_version)
	node_version=$(node_version)

	echo_ongoing "Testing Yii Clone Workflow"
	execute "yii_clone $url $branch $name $php_version $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

### NODEJS WORKFLOWS

# Test ViteJS New Workflow
function test_vite_clone_workflow() {
	local url="https://github.com/lazybox-examples/vite-react-test.git"
	local branch="develop"
	local name="vite-clone-$RANDOM"
	local php_version
	local node_version

	php_version=$(php_version)
	node_version=$(node_version)

	echo_ongoing "Testing ViteJS Clone Workflow"
	execute "vite_clone $url $branch $name $php_version $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Vanilla New Workflow
function test_vite_vanilla_new_workflow() {
	local name="vite-vanilla-new-$RANDOM"

	echo_ongoing "Testing Vite Vanilla New Workflow"
	execute "vite_vanilla_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Vanilla TypeScript New Workflow
function test_vite_vanilla_ts_new_workflow() {
	local name="vite-vanilla-ts-new-$RANDOM"

	echo_ongoing "Testing Vite Vanilla TypeScript New Workflow"
	execute "vite_vanilla_ts_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Vue New Workflow
function test_vite_vue_new_workflow() {
	local name="vite-vue-new-$RANDOM"

	echo_ongoing "Testing Vite Vue New Workflow"
	execute "vite_vue_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Vue TypeScript New Workflow
function test_vite_vue_ts_new_workflow() {
	local name="vite-vue-ts-new-$RANDOM"

	echo_ongoing "Testing Vite Vue TypeScript New Workflow"
	execute "vite_vue_ts_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite React New Workflow
function test_vite_react_new_workflow() {
	local name="vite-react-new-$RANDOM"

	echo_ongoing "Testing Vite React New Workflow"
	execute "vite_react_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite React TypeScript New Workflow
function test_vite_react_ts_new_workflow() {
	local name="vite-react-ts-new-$RANDOM"

	echo_ongoing "Testing Vite React TypeScript New Workflow"
	execute "vite_react_ts_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite React SWC New Workflow
function test_vite_react_swc_new_workflow() {
	local name="vite-react-swc-new-$RANDOM"

	echo_ongoing "Testing Vite React SWC New Workflow"
	execute "vite_react_swc_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite React SWC TypeScript New Workflow
function test_vite_react_swc_ts_new_workflow() {
	local name="vite-react-swc-ts-new-$RANDOM"

	echo_ongoing "Testing Vite React SWC TypeScript New Workflow"
	execute "vite_react_swc_ts_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Preact New Workflow
function test_vite_preact_new_workflow() {
	local name="vite-preact-new-$RANDOM"

	echo_ongoing "Testing Vite Preact New Workflow"
	execute "vite_preact_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Preact TypeScript New Workflow
function test_vite_preact_ts_new_workflow() {
	local name="vite-preact-ts-new-$RANDOM"

	echo_ongoing "Testing Vite Preact TypeScript New Workflow"
	execute "vite_preact_ts_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Lit New Workflow
function test_vite_lit_new_workflow() {
	local name="vite-lit-new-$RANDOM"

	echo_ongoing "Testing Vite Lit New Workflow"
	execute "vite_lit_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Lit TypeScript New Workflow
function test_vite_lit_ts_new_workflow() {
	local name="vite-lit-ts-new-$RANDOM"

	echo_ongoing "Testing Vite Lit TypeScript New Workflow"
	execute "vite_lit_ts_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Svelte New Workflow
function test_vite_svelte_new_workflow() {
	local name="vite-svelte-new-$RANDOM"

	echo_ongoing "Testing Vite Svelte New Workflow"
	execute "vite_svelte_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Svelte TypeScript New Workflow
function test_vite_svelte_ts_new_workflow() {
	local name="vite-svelte-ts-new-$RANDOM"

	echo_ongoing "Testing Vite Svelte TypeScript New Workflow"
	execute "vite_svelte_ts_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Solid New Workflow
function test_vite_solid_new_workflow() {
	local name="vite-solid-new-$RANDOM"

	echo_ongoing "Testing Vite Solid New Workflow"
	execute "vite_solid_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Solid TypeScript New Workflow
function test_vite_solid_ts_new_workflow() {
	local name="vite-solid-ts-new-$RANDOM"

	echo_ongoing "Testing Vite Solid TypeScript New Workflow"
	execute "vite_solid_ts_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Qwik New Workflow
function test_vite_qwik_new_workflow() {
	local name="vite-qwik-new-$RANDOM"

	echo_ongoing "Testing Vite Qwik New Workflow"
	execute "vite_qwik_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test Vite Qwik TypeScript New Workflow
function test_vite_qwik_ts_new_workflow() {
	local name="vite-qwik-ts-new-$RANDOM"

	echo_ongoing "Testing Vite Qwik TypeScript New Workflow"
	execute "vite_qwik_ts_new $name $(node_version)"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test NextJS New Workflow
function test_next_new_workflow() {
	local framework_version="latest"
	local name="next-new-$RANDOM"
	local node_version

	node_version=$(node_version)

	echo_ongoing "Testing NextJS New Workflow"
	execute "next_new $name $framework_version $node_version --js --no-eslint --no-tailwind --src-dir --no-app --import-alias @/*"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test NextJS New Workflow
function test_next_clone_workflow() {
	local url="https://github.com/lazybox-examples/next-test.git"
	local branch="develop"
	local name="next-clone-$RANDOM"
	local node_version

	node_version=$(node_version)

	echo_ongoing "Testing NextJS Clone Workflow"
	execute "next_clone $url $branch $name $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test AstroJS New Workflow
function test_astro_new_workflow() {
	local framework_version="latest"
	local name="astro-new-$RANDOM"
	local node_version

	node_version=$(node_version)

	echo_ongoing "Testing AstroJS New Workflow"
	execute "astro_new $name $framework_version $node_version --template blog --no-typescript --skip-houston --yes"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test AstroJS New Workflow
function test_astro_clone_workflow() {
	local url="https://github.com/lazybox-examples/astro-test.git"
	local branch="develop"
	local name="astro-clone-$RANDOM"
	local node_version

	node_version=$(node_version)

	echo_ongoing "Testing AstroJS Clone Workflow"
	execute "astro_clone $url $branch $name $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test GatsbyJS New Workflow
function test_gatsby_new_workflow() {
	local framework_version="latest"
	local name="gatsby-new-$RANDOM"
	local node_version

	node_version=$(node_version)

	echo_ongoing "Testing GatsbyJS New Workflow"
	execute "gatsby_new $name $framework_version $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}

# Test GatsbyJS New Workflow
function test_gatsby_clone_workflow() {
	local url="https://github.com/lazybox-examples/gatsby-test.git"
	local branch="develop"
	local name="gatsby-clone-$RANDOM"
	local node_version

	node_version=$(node_version)

	echo_ongoing "Testing GatsbyJS Clone Workflow"
	execute "gatsby_clone $url $branch $name $node_version"
	execute "echo_test_service $name.$TLD_SUFFIX"
}
