# Wallet Tracker System

A Ruby on Rails API with Vue.js frontend for managing user wallets and tracking transactions with advanced security features.

## Features

- **User Authentication**: Secure registration and login system with JWT tokens
- **Session Management**: Automatic session expiration with activity tracking and warning notifications
- **User Management**: Create and manage users with wallet balances
- **Product Catalog**: Fetch products from external API (Fake Store API)
- **Wallet Operations**: Top up wallet and purchase products
- **Transaction Tracking**: Complete history of all wallet transactions
- **Real-time Updates**: Live balance updates and transaction history
- **Modern UI**: Mobile Optimizable, Responsive Vue.js frontend with Tailwind CSS
- **Security**: Session expiration after 30 minutes of inactivity with warning notifications
- **Background Jobs**: Automated product refresh using Sidekiq
- **Responsive Design**: Works seamlessly on desktop and mobile devices

## Tech Stack

### Backend

- **Ruby on Rails 8.0.1** - API framework
- **PostgreSQL** - Database
- **bcrypt** - Password hashing and authentication
- **JWT** - Token-based authentication
- **HTTParty** - HTTP client for external API calls
- **Sidekiq** - Background job processing
- **Rack CORS** - Cross-origin resource sharing

### Frontend

- **Vue.js 3** - Progressive JavaScript framework
- **Vite** - Build tool and dev server
- **Tailwind CSS** - Utility-first CSS framework
- **Axios** - HTTP client for API communication

## Database Schema

### Users Table

- `id` (Primary Key)
- `name` (String)
- `email` (String, unique)
- `password_digest` (String)
- `credit` (Decimal)

### Products Table

- `id` (Primary Key)
- `name` (String)
- `price` (Decimal)
- `description` (Text)
- `image_url` (String)
- `external_id` (Integer, unique)

### Transactions Table

- `id` (Primary Key)
- `user_id` (Foreign Key)
- `transaction_type` (String: 'purchase' or 'top_up')
- `amount` (Decimal)
- `product_id` (Foreign Key, optional)
- `created_at` (Timestamp)

## Setup Instructions

### Prerequisites

- Ruby 3.4.2+
- Rails 8.0.1+
- PostgreSQL
- Node.js 18+
- npm or yarn

### Backend Setup

1. **Install dependencies**

   ```
   bundle install
   ```

2. **Database setup**

   ```
   rails db:create
   rails db:migrate
   rails db:seed
   ```

3. **Start the Rails server**
   ```
   rails server
   ```
   The API will be available at `http://localhost:3000`

### Frontend Setup

1. **Install Node.js dependencies**

   ```
   npm install
   ```

2. **Start the development server**
   ```
   npm run dev
   ```
   The frontend will be available at `http://localhost:3001`

## API Endpoints

### Authentication

- `POST /api/register` - Register a new user
- `POST /api/login` - User login
- `POST /api/logout` - User logout

### User Profile (Authenticated)

- `GET /api/profile` - Get current user profile with transactions
- `POST /api/top_up` - Top up user wallet
- `POST /api/purchase` - Purchase a product
- `GET /api/transactions` - Get user transaction history

### Products

- `GET /api/products` - List all available products
- `GET /api/products/:id` - Get product details
- `POST /api/products/fetch_from_api` - Fetch products from external API

### Admin (User Management)

- `GET /api/users` - List all users (admin)
- `POST /api/users` - Create a new user (admin)

## Usage

1. **Start both servers** (Rails API and Vue.js frontend)
2. **Open the frontend** at `http://localhost:3001`
3. **Register a new account** or login with existing credentials
4. **Top up your wallet** using the top-up form
5. **Browse products** and make purchases
6. **View transaction history** in real-time
7. **Session management** - Stay active or extend session when warned

## Security Features

### Session Management

The application includes comprehensive session security:

- **Automatic Session Expiration**: Sessions automatically expire after 30 minutes of inactivity
- **Activity Tracking**: Monitors user activity including mouse movements, clicks, keyboard input, and scrolling
- **Warning Notifications**: Users receive a 5-minute warning before session expiration
- **Session Extension**: Users can extend their session by clicking "Stay Logged In" in the warning
- **Secure Logout**: Complete cleanup of session data and authentication tokens

### Authentication

- **JWT Token-based Authentication**: Secure token-based authentication system
- **Password Security**: Passwords are hashed using bcrypt with minimum 6-character requirement
- **Token Expiration**: JWT tokens expire after 24 hours for enhanced security
- **Input Validation**: Comprehensive validation for all user inputs

## Background Jobs

The system includes background jobs for automated operations:

- `FetchProductsJob` - Fetches products from Fake Store API
- **Automatic Product Refresh** - Products are automatically refreshed every hour using Sidekiq

### Setting up Automatic Product Refresh

#### For Development (No Redis Required)

1. **Run the recurring job manually**

   ```
   # Run once for testing
   rails recurring:fetch_products

   # Start automatic hourly refresh (runs in foreground)
   rails recurring:start
   ```

#### For Production (Requires Redis)

1. **Install Redis** (required for Sidekiq)

   ```
   # On macOS with Homebrew
   brew install redis
   brew services start redis

   # On Ubuntu/Debian
   sudo apt-get install redis-server
   sudo systemctl start redis-server
   ```

2. **Install the new gem**

   ```
   bundle install
   ```

3. **Start Sidekiq with recurring jobs**

   ```
   bundle exec sidekiq -r ./config/sidekiq.rb
   ```

4. **Verify the job is running**
   - Check the Sidekiq logs for "Starting to fetch products from API..." messages
   - Products will be automatically refreshed every hour

### Manual Product Refresh

You can still manually refresh products using the API endpoint:

```
POST /api/products/fetch_from_api
```

## Validation Rules

- Users cannot purchase products with insufficient funds
- All transactions are atomic (use database transactions)
- Email addresses must be unique and valid
- Product prices must be greater than 0
- Top-up amounts must be positive
- Passwords must be at least 6 characters long
- Password confirmation must match during registration

## Running the Application

### Required Processes

This application requires **two separate processes** to run completely:

1. **Rails API Server** - Handles HTTP requests and API endpoints
2. **Automatic Product Refresh** - Background job that updates products every hour

### Step-by-Step Setup

#### Terminal 1: Start the Rails API Server

```
cd wallet_tracker
rails server
```

The API will be available at `http://localhost:3000`

#### Terminal 2: Start the Automatic Product Refresh

**For Testing (Quick - 2 minutes):**

```
cd wallet_tracker
rails recurring:demo
```

This runs every 30 seconds for 2 minutes

**For Development (Hourly):**

```
cd wallet_tracker
rails recurring:start
```

This will automatically refresh products every hour.

### Verification

1. **Check API is working**: Visit `http://localhost:3000/api/products`
2. **Check automatic refresh**: Watch Terminal 2 for hourly refresh messages
3. **Test manual refresh**: `POST http://localhost:3000/api/products/fetch_from_api`

Thank you
Dulanaka Siriwardana
