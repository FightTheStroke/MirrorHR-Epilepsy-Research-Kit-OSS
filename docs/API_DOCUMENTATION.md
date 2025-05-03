# API Documentation

## Overview

This document provides detailed information about the MirrorHR API endpoints, request/response formats, and authentication methods.

At MirrorHR, we believe it is fundamental to co-design and co-develop our API and digital health solutions with patients, for patients. The needs and feedback of those living with epilepsy and their families are central to the design and evolution of our API and data access policies.

## Base URL

```text
https://api.mirrorhr.org/v1
```

## Authentication

### OAuth 2.0

All API requests must be authenticated using OAuth 2.0 Bearer tokens.

```http
Authorization: Bearer <access_token>
```

### Token Types

- **Access Token**: Short-lived token for API access
- **Refresh Token**: Long-lived token for obtaining new access tokens
- **ID Token**: Contains user information

## Endpoints

### Health Data

#### Get User Health Data

```http
GET /health-data/{userId}
```

**Parameters:**

- `userId` (path): User identifier
- `startDate` (query): Start date for data range (ISO 8601)
- `endDate` (query): End date for data range (ISO 8601)
- `dataType` (query): Type of health data (e.g., "heartRate", "steps")

**Response:**

```json
{
  "data": [
    {
      "timestamp": "2024-03-20T10:00:00Z",
      "value": 75,
      "unit": "bpm",
      "source": "watch"
    }
  ],
  "metadata": {
    "count": 1,
    "startDate": "2024-03-20T00:00:00Z",
    "endDate": "2024-03-20T23:59:59Z"
  }
}
```

#### Upload Health Data

```http
POST /health-data/{userId}
```

**Request Body:**

```json
{
  "data": [
    {
      "timestamp": "2024-03-20T10:00:00Z",
      "value": 75,
      "unit": "bpm",
      "source": "watch"
    }
  ]
}
```

**Response:**

```json
{
  "status": "success",
  "uploadedCount": 1,
  "failedCount": 0
}
```

### User Management

#### Get User Profile

```http
GET /users/{userId}
```

**Response:**

```json
{
  "id": "user123",
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "preferences": {
    "language": "en",
    "timezone": "UTC",
    "notifications": true
  }
}
```

#### Update User Profile

```http
PATCH /users/{userId}
```

**Request Body:**

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "preferences": {
    "language": "en",
    "timezone": "UTC"
  }
}
```

### Notifications

#### Send Notification

```http
POST /notifications
```

**Request Body:**

```json
{
  "userId": "user123",
  "type": "alert",
  "title": "High Heart Rate",
  "message": "Your heart rate is above normal levels",
  "priority": "high"
}
```

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Invalid request parameters",
    "details": {
      "field": "startDate",
      "reason": "must be a valid ISO 8601 date"
    }
  }
}
```

### Common Error Codes

- `INVALID_REQUEST`: Invalid request parameters
- `UNAUTHORIZED`: Missing or invalid authentication
- `FORBIDDEN`: Insufficient permissions
- `NOT_FOUND`: Resource not found
- `RATE_LIMITED`: Too many requests
- `SERVER_ERROR`: Internal server error

## Rate Limiting

- 100 requests per minute per user
- 1000 requests per hour per user
- Rate limit headers included in all responses

## Webhooks

### Event Types

- `health_data.updated`
- `user.profile_updated`
- `notification.sent`

### Webhook Payload

```json
{
  "event": "health_data.updated",
  "timestamp": "2024-03-20T10:00:00Z",
  "data": {
    "userId": "user123",
    "dataType": "heartRate",
    "count": 1
  }
}
```

## SDKs

### Swift

```swift
import MirrorHRKit

let client = MirrorHRClient(apiKey: "your-api-key")
let healthData = try await client.getHealthData(
    userId: "user123",
    startDate: startDate,
    endDate: endDate
)
```

### JavaScript

```javascript
const client = new MirrorHRClient({
  apiKey: 'your-api-key'
});

const healthData = await client.getHealthData({
  userId: 'user123',
  startDate: startDate,
  endDate: endDate
});
```

## Support

For API questions:

- Email: <helpme@mirrorhr.org>
- Documentation: [docs/](./docs/)
- API Status: [status.mirrorhr.org](https://status.mirrorhr.org)

## License

Copyright © FightTheStroke Foundation

Released under MIT License
