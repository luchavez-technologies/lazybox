# Run all start.sh files inside vhosts
for vhost in /shared/httpd/*; do
  if [ -f "$vhost/start.sh" ]; then
    su -c "cd $vhost; ./start.sh" -l devilbox
  fi
done
