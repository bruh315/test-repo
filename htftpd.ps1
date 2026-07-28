$server = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Any, 1080);
$server.Start()

while ($true) {
	$client = $server.AcceptTcpClient()
	$stream = $client.GetStream();
	$sr = [System.IO.StreamReader]::new($stream);
	$sw = [System.IO.StreamWriter]::new($stream);
	$sw.AutoFlush = $true;
	
	$request = $sr.ReadLine();
	if (!$request) {
		$client.Close();
		continue;
	}
	if ($request.StartsWith("GET ")) {
		$path = $request.Split(" ")[1].Substring(1);
		$path
		if (Test-Path $path) {
			$contents = [System.IO.File]::ReadAllBytes($path);
			$header = @"
HTTP/1.1 200 OK
Content-Length: $($contents.Length)
Content-Type: application/octet-stream
Connection: close


"@
			$header = [System.Text.Encoding]::ASCII.GetBytes($header);
			$stream.Write($header, 0, $header.Length);
			$stream.Write($contents, 0, $contents.Length);
			$client.Close();
		} else {
			$sw.WriteLine("HTTP/1.1 404 Not Found");
			$sw.WriteLine("Content-Length: 4");
			$sw.WriteLine();
			$sw.WriteLine("Nah");
			$client.Close();
		}
	}
	else {
		$sw.WriteLine("HTTP/1.1 405 Method Not Allowed");
		$sw.WriteLine("Content-Length: 4");
		$sw.WriteLine();
		$sw.WriteLine("Nah");
	}
}