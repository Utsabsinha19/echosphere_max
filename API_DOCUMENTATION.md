# EchoSphere API Documentation

## Base URL
`https://api.echosphere.app/v1`

## Authentication
```javascript
Headers: {
  "Authorization": "Bearer <WALLET_SIGNED_TOKEN>",
  "Content-Type": "application/json"
}
```

## Core Endpoints

### Posts
**Create Post**
```
POST /posts
Body: {
  "content": string,
  "isAR": boolean,
  "isPublic": boolean,
  "metadata": {
    "emotionType": string,
    "arAssets": string[] 
  }
}
```

**Get Feed**
```
GET /feed?type=[public|private]&page=1&limit=20
```

**Interact with Post**
```
POST /posts/:id/interact
Body: {
  "action": "like|tip|share|comment",
  "value?: number // For tips
}
```

## AI Services

**Generate Summary**
```
POST /ai/summarize
Body: {
  "content": string,
  "length": "short|medium|long" 
}
```

**Analyze Sentiment**
```
POST /ai/sentiment
Body: {
  "text": string
}
Response: {
  "emotion": string,
  "score": number
}
```

## AR Services

**Upload AR Content**
```
PUT /ar/upload
Headers: {
  "Content-Type": "multipart/form-data"
}
Body: FormData with 3D model files
```

**Get AR Content**
```
GET /ar/:contentId
```

## Wallet Integration

**Verify Ownership**
```
GET /wallet/verify?address=0x...
```

**Process Tip**
```
POST /transactions/tip
Body: {
  "from": string,
  "to": string,
  "postId": string,
  "amount": number,
  "signature": string
}
```

## Webhooks

**Post Events**
```
POST /webhooks/events
Headers: {
  "X-Signature": string
}
Body: {
  "event": "new_post|interaction",
  "data": object
}
```

## Rate Limits
- 100 requests/minute
- 5000 requests/day

## Error Codes
| Code | Meaning |
|------|---------|
| 401 | Unauthorized |
| 403 | Forbidden |
| 429 | Rate Limited |
| 500 | Server Error |
