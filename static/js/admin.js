function login() {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    validate_user(username, password).then((data) => {
        if (data) {
            window.location.href = '/student';
        } 
        else {
            alert('Login failed. Please check your username and password.');
        }
     });
}

function validate_user(username, password) {
    const data = {
      username: username,
      password: password
    };
    
    const requestOptions = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(data)
    };
    
    return fetch(admin_login, requestOptions)
      .then(response => response.json())
      .then(data => {
          if (data.statusCode === 200) {
              console.log(data.statusCode);
              return true;
          } else {
              return false;
          }
      })
      .catch(error => {
          console.error('Error:', error);
          return false; // return false in case of any error
      });
}
