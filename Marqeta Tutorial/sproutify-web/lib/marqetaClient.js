import axios from 'axios';

function createClient(baseUrl, username, password) {
  // https://github.com/axios/axios#axioscreateconfig
  return axios.create({
    baseURL: baseUrl || 'https://sandbox-api.marqeta.com/v3/',
    timeout: 1000,
    auth: {
      username: username || '360f8a7d-7a57-4fce-a73a-e206cd19a1ea',
      password: password || '06fe1f08-3c2d-400a-8eb9-5cd3f9e4a2a0'
    },
  })
}

export default createClient()
