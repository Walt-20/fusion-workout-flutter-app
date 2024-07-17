const express = require('express');
const httpProxy = require('http-proxy');
const request = require('request');

const app = express();
const proxy = httpProxy.createProxyServer();

app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
    next();
});

// OAuth2 server details
const oauthServerUrl = 'https://oauth.fatsecret.com/connect/token';
const clientId = '634f2a4e10fd47f09ad31ae5db02b67f';
const clientSecret = '8ea8f9f27a0c47d7b3bd64e5691272b0';

// Endpoint to get OAuth2 token
app.get('/get-token', (req, res) => {
  // OAuth2 token request options
  const options = {
    method: 'POST',
    url: oauthServerUrl,
    auth: {
      user: clientId,
      password: clientSecret
    },
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    form: {
      grant_type: 'client_credentials',
      scope: 'basic'
    },
    json: true
  };

  // Make request to OAuth2 server
  request(options, function (error, response, body) {
    if (error) {
      console.error('Error getting OAuth2 token:', error);
      return res.status(500).json({ error: 'Failed to get OAuth2 token' });
    }

    // Return the OAuth2 token to the client (your Flutter app)
    res.json({ access_token: body.access_token });
  });
});

// Handle errors from the proxy
proxy.on('error', (err, req, res) => {
  console.error('Proxy error:', err);
  res.status(500).send('Proxy Error');
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`OAuth Proxy Server running on port ${PORT}`);
});
