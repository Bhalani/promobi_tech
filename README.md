# Course Tutor API

A Ruby on Rails API application that manages courses and their tutors, implementing the business rule that a tutor can only be assigned to one course.

## Tech Stack

- Ruby on Rails (API mode)
- PostgreSQL
- RSpec for testing

## Core Features

1. Create a course with its tutors
    a. Enforce one course per tutor rule
2. List all courses with their tutors

## Setup

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate

# Run tests
bundle exec rspec

# Run code style checks
bundle exec rubocop

# Start server
rails server
```

## API Endpoints

### Create Course with Tutors
```http
POST /api/v1/courses

Request:
{
  "course": {
    "name": "Ruby Programming",
    "tutors_attributes": [
      {
        "name": "John Doe",
        "email": "john@example.com"
      }
    ]
  }
}

Success Response (200 OK):
{
  "success": true,
  "data": {
    "id": 1,
    "name": "Ruby Programming",
    "tutors": [
      {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
      }
    ]
  }
}

Error Response (422 Unprocessable Entity):
{
  "success": false,
  "errors": {
    "base": ["cannot change course once assigned"]
  }
}
```

### List All Courses
```http
GET /api/v1/courses

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Ruby Programming",
      "tutors": [
        {
          "id": 1,
          "name": "John Doe",
          "email": "john@example.com"
        }
      ]
    }
  ]
}
```

## Code Organization

```
app/
├── contracts/           # Input validation
│   └── api/v1/
│       └── course_contract.rb
├── controllers/         # API endpoints
│   └── api/v1/
│       └── courses_controller.rb
├── models/             # Data models and validations
│   ├── course.rb
│   └── tutor.rb
├── operations/         # Business logic
│   └── api/v1/
│       └── course_operations/
│           ├── create.rb
│           └── list.rb
└── serializers/        # JSON response formatting
    ├── course_serializer.rb
    └── tutor_serializer.rb
```

## Key Gems Used

1. **dry-validation**
   - Handle input validation
   - Manage business operations
   - Provide clean error handling

2. **active_model_serializers**
   - Format JSON responses
   - Handle model relationships in JSON

3. **rspec-rails & factory_bot_rails**
   - Test framework and factories
   - Model and request specs

4. **rubocop**
   - Enforce code style
   - Maintain code quality

## Testing

The codebase includes:
- Model specs: Testing validations and associations
- Request specs: Testing API endpoints and responses

Run tests with:
```bash
bundle exec rspec
```

## Business Rules

1. A course can have multiple tutors
2. A tutor can teach only one course
3. Cannot change a tutor's course once assigned
4. Tutor emails must be unique
