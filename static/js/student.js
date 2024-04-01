document.getElementById('submitButton').addEventListener('click', function(event) {
    event.preventDefault();

    var studentId = document.getElementById('student-id').value;
    var firstName = document.getElementById('firstname').value;
    var middleName = document.getElementById('middlename').value;
    var lastName = document.getElementById('lastname').value;
    var gender = document.getElementById('gender').value;
    var yearLevel = document.getElementById('yearlevel').value;
    var course = document.getElementById('course').value;


    student_dict = {id: studentId, firstName: firstName,
        middleName: middleName, lastName: lastName,
        yearLevel: yearLevel, gender: gender,
        course: course, type: "add"};
    perform_lambda_request(student_dict, student_lambda).then((data) => {
        console.log(data);
     });
    location.reload();
});

document.getElementById('updateStudentBtn').addEventListener('click', function(event) {
    event.preventDefault();

    var studentId = document.getElementById('student-id-update').value;
    var firstName = document.getElementById('firstname-update').value;
    var middleName = document.getElementById('middlename-update').value;
    var lastName = document.getElementById('lastname-update').value;
    var gender = document.getElementById('gender-update').value;
    var yearLevel = document.getElementById('yearlevel-update').value;
    var course = document.getElementById('course-update').value;


    student_dict = {id: studentId, firstName: firstName,
        middleName: middleName, lastName: lastName,
        yearLevel: yearLevel, gender: gender,
        course: course, type: "update"};
    perform_lambda_request(student_dict, student_lambda).then((data) => {
        console.log(data);
        location.reload();
     });
});


document.getElementById('logout').addEventListener('click', function(event) {
    window.location.href = '/admin';
});

document.getElementById('searchForm').addEventListener('submit', function(event) {
    event.preventDefault();
    var keyword = document.getElementById('searchField').value;
    var sort_by = document.getElementById('field').value;
    search_dict = {keyword: keyword, sort_by: sort_by, type: "search"};
    if (sort_by == "select") {
        search_dict = {type: "search"};
    }
    
    perform_lambda_request(search_dict, student_lambda).then((data) => {
        updateTable(data);
     });
});


function updateTable(data) {
    document.getElementById('studentData').innerHTML = '';
    data = data.body;

    data.forEach(student => {
        const newRow = document.createElement('tr');
        console.log(student);
        newRow.innerHTML = `
            <td>${student[0]}</td>
            <td><img src="../images/student-profile-template.png" alt="Student Photo"></td>
            <td>${student[1]} ${student[2]} ${student[3]}</td>
            <td>${student[4]}</td>
            <td>${student[5]}</td>
            <td>${student[6]}</td>
            <td>
                <button class="btn btn-warning update-btn" data-bs-toggle="modal" data-bs-target=#updateStudentModal data-student='${JSON.stringify(student)}'>Update</button>
                <button class="btn btn-danger delete-btn" data-student-id='${student.id}'>Delete</button>
            </td>
        `;
        document.getElementById('studentData').appendChild(newRow);
    });

    document.querySelectorAll('.update-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            const studentData = JSON.parse(this.getAttribute('data-student'));
            populateModal(studentData);
        });
    });

    document.querySelectorAll('.delete-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            const studentId = JSON.parse(this.previousElementSibling.getAttribute('data-student'))[0];
            if (confirm('Are you sure you want to delete this student?')) {
                console.log(studentId);
                perform_lambda_request({type: "delete", id: studentId},
                    student_lambda).then(() => {
                    location.reload();
                 });

            }
        });
    });
}

function populateModal(studentData) {
    // Populate modal fields with student data
    console.log(studentData);
    document.getElementById('student-id-update').value = studentData[0];
    document.getElementById('firstname-update').value = studentData[1];
    document.getElementById('middlename-update').value = studentData[2];
    document.getElementById('lastname-update').value = studentData[3];
    document.getElementById('gender-update').value = studentData[4];
    document.getElementById('yearlevel-update').value = studentData[5];
    document.getElementById('course-update').value = studentData[7];
}

window.onload = function() {
    perform_lambda_request({"type": "get_all_students"}, student_lambda).then((data) => {
        updateTable(data);
     });
}

function perform_lambda_request(data, url) {        
        const requestOptions = {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(data)
        };

        console.log(requestOptions);
        
        return fetch(url, requestOptions)
          .then(response => response.json())
          .then(data => {
              if (data.statusCode === 200) {
                  console.log(data);
                  return data;
              } else {
                console.log(data.statusCode);
                  return false;
              }
          })
          .catch(error => {
              console.error('Error:', error);
              return false;
          });
    }
    