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
// {'statusCode': 200, 'body': [['2019-0002', 'Wali', 'Wa', 'To', 'Male', 1, 'BSCE', 'Bachelor of Science in Civil Engineering', 'COET', 'College of Engineering and Technology'], ['2019-0000', 'Andrzej', 'Test', 'Owy', 'Bisexual', 1, 'BSCE', 'Bachelor of Science in Civil Engineering', 'COET', 'College of Engineering and Technology'], ['2018-0000', 'Sam', 'Will', 'Jenkish', 'Male', 2, 'BSCE', 'Bachelor of Science in Civil Engineering', 'COET', 'College of Engineering and Technology']]}
// Function to update table with new data
function updateTable(data) {
    // Clear previous data
    document.getElementById('studentData').innerHTML = '';

    // Append new data to the table
    data.forEach(student => {
        const newRow = document.createElement('tr');
        // Create and append table cells based on student data
        // Example:
        newRow.innerHTML = `
            <td>${student.id}</td>
            <td><img src="${student.photo}" alt="Student Photo"></td>
            <td>${student.name}</td>
            <td>${student.gender}</td>
            <td>${student.level}</td>
            <td>${student.course}</td>
            <td>
                <button class="btn btn-warning update-btn" data-bs-toggle="modal" data-bs-target=#updateStudentModal data-student='${JSON.stringify(student)}'>Update</button>
                <button class="btn btn-danger delete-btn" data-student-id='${student.id}'>Delete</button>
            </td>
        `;
        document.getElementById('studentData').appendChild(newRow);
    });

    // Add event listeners to the update and delete buttons
    document.querySelectorAll('.update-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            const studentData = JSON.parse(this.dataset.student);
            populateModal(studentData);
        });
    });

    document.querySelectorAll('.delete-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            const studentId = this.dataset.studentId;
            if (confirm('Are you sure you want to delete this student?')) {
                deleteStudent(studentId); // Call a function to delete the student
            }
        });
    });
}

function populateModal(studentData) {
    // Populate modal fields with student data
    console.log(studentData);
    document.getElementById('student-id-update').value = studentData.id;
    document.getElementById('firstname-update').value = studentData.firstname;
    document.getElementById('middlename-update').value = studentData.middlename;
    document.getElementById('lastname-update').value = studentData.lastname;
    document.getElementById('gender-update').value = studentData.gender;
    document.getElementById('yearlevel-update').value = studentData.level;
    document.getElementById('course-update').value = studentData.course;
}

window.onload = function() {
    // Mock student data for testing purposes
    const mockStudentData = [
        { id: '1', photo: '../images/student-profile-template.png', name: 'John Doe', gender: 'Male', level: '1', course: 'Computer Science' },
        { id: '2', photo: '../images/student-profile-template.png', name: 'Jane Smith', gender: 'Female', level: '2', course: 'Mathematics' }
        // Add more mock data as needed
    ];

    // Call updateTable with mock data
    updateTable(mockStudentData);}