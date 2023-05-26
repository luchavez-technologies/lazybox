read -rp "The volumes will be deleted. Are you sure you want to proceed? (y/n) " choice
case "$choice" in
  y|Y )
    if hash docker-compose 2>/dev/null; then
    	prepend="docker-compose"
    else
    	prepend="docker compose"
    fi

    $prepend down -v
    ;;
  n|N )
    echo "Execution cancelled."
    ;;
  * )
    echo "Invalid choice."
    ;;
esac
