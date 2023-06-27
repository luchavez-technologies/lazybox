<?php require '../config.php'; ?>
<?php loadClass('Helper')->authPage(); ?>
<!DOCTYPE html>
<html lang="en">
<head>
	<?php echo loadClass('Html')->getHead(); ?>
</head>

<body>
<?php echo loadClass('Html')->getNavbar(); ?>

<div class="container">
	<?php echo loadClass('Html')->getWorkspace(); ?>
	<div class="embed-responsive embed-responsive-16by9">
		<iframe class="embed-responsive-item" src="https://minio.dvl.to/browser" allowfullscreen></iframe>
	</div>
</div><!-- /.container -->

<?php echo loadClass('Html')->getFooter(); ?>
</body>
</html>
