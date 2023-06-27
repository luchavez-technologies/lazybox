<?php

namespace devilbox;

class AddonService extends BaseClass implements BaseInterface
{
	/**
	 * Hostname
	 * @var array
	 */
	protected array $_data = [];

	/**
	 * @param $hostname
	 * @param array $data
	 */
	public function __construct($hostname, $data = array())
	{
		parent::__construct($hostname, $data);

		$this->_data = $data;
	}


	public function canConnect(&$err, $hostname, $data = array())
	{
		$err = false;

		// Return if already cached
		if (isset($this->_can_connect[$hostname])) {
			// Assume error for unset error message
			$err = $this->_can_connect_err[$hostname] ?? true;
			return $this->_can_connect[$hostname];
		}

		$ch = curl_init();
		$port=$data['port'] ?? 80;
		$endpoint=$data['endpoint'] ?? '';

		curl_setopt($ch, CURLOPT_URL, "http://$hostname:$port$endpoint");
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_HEADER, 1);
		curl_exec($ch);
		$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
		curl_close($ch);

		// Test via CURL request
		if ($http_code == 200) {
			$this->_can_connect[$hostname] = true;
		} else {
			$err = $this->getName() . " server is not online.";
			$this->_can_connect[$hostname] = false;
		}

		$this->_can_connect_err[$hostname] = $err;
		return $this->_can_connect[$hostname];
	}

	public function getName($default = ''): string
	{
		return strtoupper($this->_hostname);
	}

	public function getVersion()
	{
		// Return if already cached
		if (isset($this->_version)) {
			return $this->_version;
		}

		$version_variable = $this->_data['version_variable'] ?? null;

		// Return empty if not available
		if (!$this->isAvailable() || is_null($version_variable)) {
			$this->_version = '';
			return $this->_version;
		}

		$version = loadClass('Helper')->getEnv($version_variable);

		if (!$version) {
			$name = $this->getName();
			loadClass('Logger')->error("Could not get $name Version");
			$this->_version = '';
		} else {
			$this->_version = $version;
		}

		return $this->_version;
	}
}
