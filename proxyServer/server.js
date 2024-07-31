import express from 'express';
import httpProxy from 'http-proxy';
import request from 'request';
import fetch from 'node-fetch';

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
let fatApiAccessToken = null;
let fatApiTokenExpiration = null;
const ninjasApiAccessToken = 'HOsWIdXrBsEI1nCv0p6TWQ==jijyLwr69j7eonaL';


// Endpoint to get OAuth2 token
app.get('/get-token', (req, res) => {
    // check that the access token has been generated and is not expired.
    if (fatApiAccessToken && fatApiTokenExpiration && fatApiTokenExpiration > Date.now()) {
      console.log(`should not be expired ${fatApiTokenExpiration} `);
      return res.json({ access_token: fatApiAccessToken });
    }
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

    // Make request to OAuth2 server using request library
    request(options, function (error, response, body) {
        if (error) {
            console.error('Error getting OAuth2 token:', error);
            return res.status(500).json({ error: 'Failed to get OAuth2 token' });
        }

        // store the new access token and it's expiration time
        fatApiAccessToken = body.access_token;
        console.log(`The access token is ${fatApiAccessToken}`);
        console.log(`The expiration of the token is ${body.expires_in}`);
        fatApiTokenExpiration = Date.now() + (body.expires_in * 1000);
        console.log(`The token will expire on ${fatApiTokenExpiration}`);

        // Return the OAuth2 token to the client (your Flutter app)
        res.json({ access_token: body.access_token });
    });
});

// Endpoint to search for food
app.get('/search-food', (req, res) => {
  // check that token is available and not expired
  if (!fatApiAccessToken || !fatApiTokenExpiration || fatApiTokenExpiration < Date.now()) {
    console.log(`Token expiration is ${fatApiTokenExpiration}`);
    return res.status(401).json({ error: 'Access token expired' });
  }
  

  // Construct the request to FatSecret API
  const baseURL = 'https://platform.fatsecret.com/rest/server.api';
  const searchExpression = req.query.searchExpression || 'pizza'; // Default search query
  const pageNumber = req.query.pageNumber || 0; // Default page number
  const maxResults = req.query.maxResults || 20; // Default max results
  const format = req.query.format || 'json'; // Default response format

  const options = {
    method: 'POST',
    url: baseURL,
    headers: {
      'Authorization': `Bearer ${fatApiAccessToken}`,
      'Content-Type': 'application/json'
    },
    qs: {
      method: 'foods.search.v3',
      search_expression: searchExpression,
      page_number: pageNumber,
      max_results: maxResults,
      format: format,
    }
  };

  // Make GET request to FatSecret API using request library
  request(options, function (error, response, body) {
      if (error) {
          console.error('Error searching for food:', error);
          return res.status(500).json({ error: 'Failed to search for food' });
      }

      // Parse the response body if it's JSON
      try {
          const parsedBody = JSON.parse(body);

          // Extract relevant data from the FatSecret API response
          const foods = parsedBody.foods && parsedBody.foods.food ? parsedBody.foods.food : [];

          // Map the data to fit Flutter's expected format (List<dynamic>)
          const foodList = foods.map(food => ({
              food_id: food.food_id,
              food_name: food.food_name,
              food_description: food.food_description,
              food_url: food.food_url,
              // Add any other fields you want to include
          }));

          console.log(`The results are ${foodList}`);

          // Send the processed data back to the client (Flutter app)
          res.json(foodList);
      } catch (error) {
          console.error('Error parsing JSON response:', error);
          res.status(500).json({ error: 'Error parsing JSON response' });
      }
  });
});

app.get('/fetch-foodId', (req, res) => {
  // check that token is available and not expired
  if (!fatApiAccessToken || !fatApiTokenExpiration || fatApiTokenExpiration < Date.now()) {
    console.log(`Token expiration is ${fatApiTokenExpiration}`);
    return res.status(401).json({ error: 'Access token expired' });
  }
  

  // Construct the request to FatSecret API
  const baseURL = 'https://platform.fatsecret.com/rest/server.api';
  const searchExpression = req.query.searchExpression;
  const format = req.query.format || 'json';

  const options = {
    method: 'GET',
    url: baseURL,
    headers: {
      'Authorization': `Bearer ${fatApiAccessToken}`,
      'Content-Type': 'application/json'
    },
    qs: {
      method: 'food.get.v4',
      food_id: searchExpression,
      format: format,
    }
  };

  request(options, function(error, response, body) {
    if (error) {
      console.error('Error fetching food ID:', error);
      return res.status(500).json({ error: 'Failed to fetch Food ID' });
    }

    try {
      const parsedBody = JSON.parse(body);

      const foods = parsedBody['food'];

      const servings = food.servings;

      console.log(servings);

      // Map the data to fit Flutter's expected format (List<dynamic>)
      const foodList = foods.map(food => ({
        food_id: food.food_id,
        food_name: food.food_name,
        food_description: food.food_description,
        food_url: food.food_url,
        // Add any other fields you want to include
    }));
    } catch (error) {
      console.error('Error parsing JSON response:', error);
      res.status(500).json({ error: 'Error parsing JSON response' });
    }
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
