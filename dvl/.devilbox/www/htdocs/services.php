<?php require '../config.php'; ?>
<?php loadClass('Helper')->authPage(); ?>
<!DOCTYPE html>
<html lang="en">
<head>
	<?php echo loadClass('Html')->getHead(true); ?>
</head>

<body>
<?php echo loadClass('Html')->getNavbar(); ?>

<div class="container">
	<?php echo loadClass('Html')->getWorkspace(); ?>

	<h1>Services</h1>
	<br/>
	<br/>

	<!-- ############################################################ -->
	<!-- Version/Health -->
	<!-- ############################################################ -->
	<div class="row">

		<!-- List of Services -->

		<?php

		$services = [
			'MySQL' => [
				'emoji' => '💾',
				'class' => 'Mysql',
				'url' => 'https://localhost/vendor/phpmyadmin-5.1.3/index.php',
				'variables' => [
					'MYSQL_SERVER',
					'HOST_PORT_MYSQL',
					'MYSQL_ROOT_PASSWORD',
				]
			],
			'PostgreSQL' => [
				'emoji' => '💾',
				'class' => 'Pgsql',
				'url' => 'https://localhost/vendor/phppgadmin-7.13.0',
				'variables' => [
					'PGSQL_SERVER',
					'HOST_PORT_PGSQL',
					'PGSQL_ROOT_USER',
					'PGSQL_ROOT_PASSWORD',
					'PGSQL_HOST_AUTH_METHOD'
				]
			],
			'MongoDB' => [
				'emoji' => '💾',
				'class' => 'Mongo',
				'url' => 'https://localhost/vendor/adminer-4.8.1-en.php?mongo=localhost&username=',
				'variables' => [
					'MONGO_SERVER',
					'HOST_PORT_MONGO',
				]
			],
			'MinIO' => [
				'emoji' => '🪣',
				'class' => 'Minio',
				'url' => 'https://minio.dvl.to',
				'variables' => [
					'MINIO_SERVER',
					'HOST_PORT_MINIO',
					'HOST_PORT_MINIO_CONSOLE',
					'MINIO_USERNAME',
					'MINIO_PASSWORD',
				]
			],
			'Redis' => [
				'emoji' => '☁️',
				'class' => 'Redis',
				'url' => 'https://localhost/vendor/phpredmin/public/index.php',
				'variables' => [
					'REDIS_SERVER',
					'HOST_PORT_REDIS',
					'REDIS_ARGS'
				]
			],
			'Memcached' => [
				'emoji' => '☁️',
				'class' => 'Memcd',
				'url' => 'https://localhost/vendor/phpmemcachedadmin-1.3.0/index.php',
				'variables' => [
					'MEMCD_SERVER',
					'HOST_PORT_MEMCD'
				]
			],
			'ngrok' => [
				'emoji' => '🌏',
				'class' => 'Ngrok',
				'url' => 'https://ngrok.dvl.to',
				'variables' => [
					'NGROK_SERVER',
					'HOST_PORT_NGROK',
					'NGROK_VHOST',
					'NGROK_HTTP_TUNNELS',
					'NGROK_AUTHTOKEN',
					'NGROK_REGION'
				]
			],
			'MailHog' => [
				'emoji' => '🐷',
				'class' => 'Mailhog',
				'url' => 'https://mailhog.dvl.to',
				'variables' => [
					'MAILHOG_SERVER',
					'HOST_PORT_MAILHOG_CONSOLE',
					'HOST_PORT_MAILHOG'
				]
			],
			'Soketi' => [
				'emoji' => '🔈',
				'class' => 'Soketi',
				'url' => 'https://soketi.dvl.to/metrics',
				'variables' => [
					'SOKETI_SERVER',
					'HOST_PORT_SOKETI',
					'SOKETI_DEFAULT_APP_ID',
					'SOKETI_DEFAULT_APP_KEY',
					'SOKETI_DEBUG',
					'SOKETI_MODE',
					'SOKETI_METRICS_ENABLED',
					'SOKETI_METRICS_DRIVER',
					'SOKETI_METRICS_PROMETHEUS_PREFIX',
					'SOKETI_DB_REDIS_HOST',
					'SOKETI_DB_REDIS_DB',
					'SOKETI_CACHE_DRIVER',
					'SOKETI_QUEUE_DRIVER',
					'SOKETI_RATE_LIMITER_DRIVER',
					'SOKETI_ADAPTER_DRIVER',
					'SOKETI_ADAPTER_REDIS_PREFIX',
					'SOKETI_DB_REDIS_KEY_PREFIX',
				]
			]
		];

		foreach ($services as $service => $arr) {
			echo loadClass('Html')->getServiceCard($arr['class'], $arr['emoji']." ".$service, $arr['url'], $arr['variables']);
		}

		?>
	</div><!-- /row -->


</div><!-- /.container -->

<?php echo loadClass('Html')->getFooter(); ?>
</body>
</html>
