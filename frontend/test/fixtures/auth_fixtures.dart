const loginResponseJson = {
  'access_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJyb2xlIjoic3R1ZGVudCIsInR5cGUiOiJhY2Nlc3MiLCJleHAiOjk5OTk5OTk5OTl9.test',
  'refresh_token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJ0eXBlIjoicmVmcmVzaCIsImV4cCI6OTk5OTk5OTk5OX0.test',
  'token_type': 'bearer',
};

const userResponseJson = {
  'id': '550e8400-e29b-41d4-a716-446655440000',
  'username': 'student01',
  'display_name': '张三',
  'role': 'student',
  'email': 'student01@example.com',
  'avatar_url': null,
  'grade': '高二',
  'class_name': '3班',
  'student_id': '20240301',
  'last_login_at': '2024-06-01T08:00:00Z',
  'created_at': '2024-01-01T00:00:00Z',
};

const registerRequestJson = {
  'username': 'newstudent',
  'password': 'pass123',
  'display_name': '李四',
  'role': 'student',
  'grade': '高一',
  'class_name': '1班',
};

const loginRequestJson = {
  'username': 'student01',
  'password': 'pass123',
};
