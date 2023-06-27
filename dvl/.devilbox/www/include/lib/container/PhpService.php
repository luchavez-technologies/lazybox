<?php

namespace devilbox;
class PhpService extends BaseClass implements BaseInterface
{
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
		curl_setopt($ch, CURLOPT_URL, "http://$hostname");
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_HEADER, 1);
		$output = curl_exec($ch);
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

	public function getName($default = ""): string
	{
		return strtoupper($this->_hostname);
	}

	public function getVersion()
	{
		// Return if already cached
		if (isset($this->_version)) {
			return $this->_version;
		}

		// Return empty if not available
		if (!$this->isAvailable()) {
			$this->_version = '';
			return $this->_version;
		}

		$string = $this->_hostname;
		$version = substr($string, 3);
		$version = str_replace(".", "", $version);
		$version = substr_replace($version, ".", -1, 0);

		$this->_version = $version;

		return $this->_version;
	}
}
