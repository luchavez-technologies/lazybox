<?php require '../config.php'; ?>
<?php loadClass('Helper')->authPage(); ?>
<!DOCTYPE html>
<html lang="en">
<head>
	<?php echo loadClass('Html')->getHead(); ?>
	<script
		type="module"
		src="https://cdn.jsdelivr.net/gh/zerodevx/zero-md@2/dist/zero-md.min.js"
	></script>
</head>

<body>
<?php echo loadClass('Html')->getNavbar(); ?>

	<div class="container">
		<?php echo loadClass('Html')->getWorkspace(); ?>

		<h1>Available Workflows</h1>
		<br/>
		<br/>
		<div class="row">
			<div class="col">
				<select id="language-select" class="form-control">
					<option value="">Select a language</option>
					<option value="php">PHP</option>
					<option value="javascript">Javascript</option>
					<option value="python">Python</option>
				</select>
			</div>
			<div class="col">
				<select id="framework-select" class="form-control" disabled>
					<option value="">Select a framework</option>
				</select>
			</div>
		</div>

		<div id="card-container" class="mt-4" style="display: none;">
			<div class="card">
				<div id="workflow" class="card-body p-3">
				</div>
			</div>
		</div>
	</div>

	<?php echo loadClass('Html')->getFooter(); ?>

	<script>
		$(document).ready(function() {
			// Framework options
			const frameworkOptions = {
				php: {
					laravel: 'Laravel',
					lumen: 'Lumen',
					symfony: 'Symfony',
					cake: 'CakePHP',
					codeigniter: 'CodeIgniter',
					yii: 'Yii',
					slim: 'SlimPHP',
					x: 'Framework X',
					drupal: 'Drupal',
					wordpress: 'Wordpress'
				},
				javascript: {
					vite: 'ViteJS',
					next: 'NextJS',
					gatsby: 'GatsbyJS',
					astro: 'AstroJS',
					strapi: 'Strapi'
				},
				python: {
					django: 'Django',
					flask: 'Flask'
				}
			};

			// Update framework options based on selected language
			$('#language-select').on('change', function() {
				let selectedLanguage = $(this).val();
				let frameworks = frameworkOptions[selectedLanguage];

				// Enable or disable the framework select based on the selected language
				if (frameworks) {
					$('#framework-select').prop('disabled', false);
				} else {
					$('#framework-select').prop('disabled', true);
					$('#framework-select').val('');
					$('#card-container').hide();
				}

				// Clear and populate the framework select options
				$('#framework-select').empty();
				$('#framework-select').append('<option value="">Select a framework</option>');
				$.each(frameworks, function(framework, display) {
					$('#framework-select').append('<option value="' + framework + '">' + display + '</option>');
				});
			});

			// Show selected framework card
			$('#framework-select').on('change', function() {
				let selectedLanguage = $('#language-select').val();
				let selectedFramework = $(this).val();
				let readme = `./markdowns/${selectedLanguage}/${selectedFramework}/README.md`;

				if (selectedLanguage && selectedFramework) {
					$('#workflow').html(`<zero-md src="${readme}"></zero-md>`);
					$('#card-container').show();
				} else {
					$('#card-container').hide();
				}
			});
		});
	</script>

</body>
</html>
