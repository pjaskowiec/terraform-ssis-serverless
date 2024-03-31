// Handle logout
document.getElementById('logout').addEventListener('click', function(event) {
    // Handle logout logic here
    // For example, redirect to logout URL
    window.location.href = '/logout';
});

// Handle search form submission
document.getElementById('searchForm').addEventListener('submit', function(event) {
    event.preventDefault(); // Prevent default form submission

    // Get form data
    const formData = new FormData(this);

    // Perform search based on formData
    // Use fetch or any AJAX method to communicate with server
    // Update the table with search results
    // Example:
    fetch('/search', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        // Update table with search results
        updateTable(data);
    })
    .catch(error => {
        console.error('Error:', error);
    });
});

// Handle limit form submission
document.getElementById('limitForm').addEventListener('submit', function(event) {
    event.preventDefault(); // Prevent default form submission

    // Get form data
    const formData = new FormData(this);

    // Perform action based on formData
    // Use fetch or any AJAX method to communicate with server
    // Update the table based on selected limit
    // Example:
    fetch('/updateLimit', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())
    .then(data => {
        // Update table with new limit
        updateTable(data);
    })
    .catch(error => {
        console.error('Error:', error);
    });
});

// Function to update table with new data
function updateTable(data) {
    // Clear previous data
    document.getElementById('courseData').innerHTML = '';

    // Append new data to the table
    data.forEach(course => {
        const newRow = document.createElement('tr');
        // Create and append table cells based on course data
        // Example:
        newRow.innerHTML = `
            <td>${course.code}</td>
            <td>${course.name}</td>
            <td>${course.college}</td>
            <td>
                <button class="btn btn-warning">Update</button>
                <button class="btn btn-danger">Delete</button>
            </td>
        `;
        document.getElementById('courseData').appendChild(newRow);
    });
}
