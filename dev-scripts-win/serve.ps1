$port = if ($env:PORT) { $env:PORT } else { 1313 }

hugo server `
  --bind "0.0.0.0" `
  --port $port `
  --baseURL "http://localhost:$port"
