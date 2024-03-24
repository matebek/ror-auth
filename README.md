# RoR Auth

RoR Auth is a playground application showcasing a simple yet elegant solution for implementing common authentication functionalities in your Ruby on Rails application.

## Features

### User Account Management

- `GET /signup`: Displays the sign up form.
- `POST /signup`: Handles the submission of the sign up form and creates a new user account.
- `DELETE /shutdown`: Deletes the user's account and associated data.

### User Authentication

- `GET /login`: Displays the login form.
- `POST /login`: Handles the submission of the login form and authenticates the user.
- `DELETE /logout`: Logs the user out and destroys the session data.

### Email Verification

- `POST /email-verification`: Initiates the email verification process by sending a unique verification link via email.
- `GET /email-verification/:token`: Verifies the user's email address. Token is valid for 1 week to perform the action.

### Password Reset

- `GET /password-reset`: Displays the forgot password form.
- `POST /password-reset`: Handles the submission of the forgot password form and initiates the password reset process by sending a unique password reset link via email.
- `GET /password-reset/:token`: Displays the password reset form.
- `PATCH /password-reset/:token`: Handles the submission of the password reset form and updates the user's password.

## Implementation Details

The [AuthService](/app/services/auth_service.rb) provides a set of methods for handling user authentication, session management, and interacting with the authenticated user. The application's `User` model must implement `has_secure_password` for these methods to work.

### AuthService

- `initialize(session, cookies) -> void`

  Initializes the `AuthService` instance with references to the session and cookies objects.

  - Parameters:
    - `session`: Session object for storing user session data.
    - `cookies`: Cookies object for managing browser cookies.

- `login(user, password, remember_me = false) -> boolean`

  Authenticates a user with the provided credentials and creates a session if successful.

  - Parameters:
    - `user`: User object representing the user attempting to log in.
    - `password`: Password provided by the user for authentication.
    - `remember_me`: Optional boolean indicating whether to create a persistent login session. Default is `false`.

- `force_login(user) -> true`

  Force login a user without requiring authentication.

  - Parameters:
    - `user`: User object representing the user to be logged in.

- `logout -> void`

  Terminates the current user session.

- `user -> User | nil`

  Retrieves the currently authenticated user.

- `user? -> boolean`

  Checks if a user is currently authenticated.

## Getting Started

To get started with RoR Auth, follow these steps:

1. **Clone the repository:**

   ```bash
   git clone git@github.com:matebek/ror-auth.git
   ```

2. **Install dependencies:**

   ```bash
   bundle install
   ```

3. **Set up the database:**

   ```bash
   rails db:create db:migrate
   ```

4. **Run the dev server:**

   ```bash
   ./bin/dev
   ```

5. **Access the Application:**

   Open your web browser and navigate to `http://localhost:3000`.

## Contributing

Contributions to RoR Auth are welcome! Feel free to fork the repository, make changes, and submit pull requests.

## License

This project is licensed under the [MIT License](LICENSE).

---

_This README is a work in progress and subject to changes and improvements._
