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

			<h1>MongoDB Info</h1>
			<br/>
			<br/>

			<div class="row">
				<div class="col-md-12">

					<?php if (!loadClass('Mongo')->isAvailable()): ?>
						<p>MongoDB container is not running.</p>
					<?php else: ?>
						<table class="table table-striped">
							<thead class="thead-inverse">
								<tr>
									<th>Variable</th>
									<th>Value</th>
								</tr>
							</thead>
							<tbody>
								<?php foreach (loadClass('Mongo')->getInfo() as $key => $val): ?>
									<tr>
										<td><?php print_r($key);?></td>
										<td class="break-word"><pre><?php print_r($val);?></pre></td>
									</tr>
								<?php endforeach; ?>
							</tbody>
						</table>
					<?php endif; ?>

				</div>
			</div>

		</div><!-- /.container -->

		<?php echo loadClass('Html')->getFooter(); ?>
	</body>
</html>
