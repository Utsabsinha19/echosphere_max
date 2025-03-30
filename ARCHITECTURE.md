# EchoSphere Architecture

```mermaid
graph TD
    A[Client App] --> B[API Gateway]
    B --> C[Authentication Service]
    B --> D[Post Service]
    B --> E[AI Service]
    B --> F[AR Service]
    B --> G[Wallet Service]
    
    C --> H[(User DB)]
    D --> I[(Post DB)]
    D --> J[IPFS Storage]
    E --> K[LLM Providers]
    F --> L[3D Model Storage]
    G --> M[Blockchain Nodes]
    
    style A fill:#4CAF50,stroke:#388E3C
    style B fill:#2196F3,stroke:#0b7dda
    style C fill:#FF9800,stroke:#e68a00
    style D fill:#FF9800,stroke:#e68a00
    style E fill:#FF9800,stroke:#e68a00
    style F fill:#FF9800,stroke:#e68a00
    style G fill:#FF9800,stroke:#e68a00
    style H fill:#9E9E9E,stroke:#424242
    style I fill:#9E9E9E,stroke:#424242
    style J fill:#607D8B,stroke:#455A64
    style K fill:#795548,stroke:#5D4037
    style L fill:#607D8B,stroke:#455A64
    style M fill:#3F51B5,stroke:#303F9F
```

## Key User Flows

### Post Creation Sequence
```mermaid
sequenceDiagram
    participant User
    participant App
    participant API
    participant Blockchain
    participant IPFS

    User->>App: Create post content
    App->>API: Submit post (unsigned)
    API->>User: Request signature
    User->>Blockchain: Sign transaction
    Blockchain-->>User: Return signature
    User->>API: Submit signed post
    API->>IPFS: Store content
    IPFS-->>API: Return CID
    API->>Blockchain: Record transaction
    Blockchain-->>API: Confirm tx
    API-->>App: Post created
    App-->>User: Show confirmation
```

### AR Post Viewing Sequence
```mermaid
sequenceDiagram
    participant User
    participant App
    participant API
    participant ARService
    participant CDN

    User->>App: Select AR post
    App->>API: Request AR content
    API->>ARService: Get model metadata
    ARService-->>API: Return manifest
    API->>CDN: Request 3D assets
    CDN-->>API: Deliver assets
    API-->>App: AR package
    App->>User: Render AR experience
```

## Key Components

### Frontend
- **Flutter Application**
  - Cross-platform mobile and web
  - State management with Provider
  - AR view integration

### Backend Services
1. **API Gateway**
   - Request routing
   - Rate limiting
   - Authentication

2. **Authentication Service**
   - Wallet-based auth
   - JWT token generation
   - Session management

3. **Post Service**
   - CRUD operations
   - Feed generation
   - Content moderation

4. **AI Service**
   - Sentiment analysis
   - Content summarization
   - Personalized recommendations

5. **AR Service**
   - 3D model processing
   - AR content delivery
   - Device compatibility

6. **Wallet Service**
   - Blockchain interactions
   - Transaction processing
   - Smart contract calls

### Data Storage
- **PostgreSQL** - Structured data
- **IPFS** - Decentralized content storage
- **S3** - AR assets and media

### External Integrations
- **Blockchain Networks** (Ethereum, Polygon)
- **AI Providers** (OpenAI, HuggingFace)
- **AR SDKs** (ARKit, ARCore)

## Data Models

### Post Model
```typescript
interface Post {
  id: string;
  content: string;
  author: string; // Wallet address
  timestamp: DateTime;
  summary?: string;
  emotionType: string;
  emotionScore: number;
  isAR: boolean;
  arContentUrl?: string;
  tipAmount: BigInt;
  viewCount: number;
  likeCount: number;
  shareCount: number;
  commentCount: number;
}
```

### User Profile
```typescript
interface UserProfile {
  walletAddress: string;
  username?: string;
  avatar?: string; // IPFS CID
  preferences: {
    theme: 'light'|'dark'|'auto';
    defaultPrivacy: 'public'|'private';
  };
  stats: {
    postCount: number;
    totalEarnings: BigInt;
  };
}
```

### Database Schema
```mermaid
erDiagram
    USER ||--o{ POST : creates
    USER {
        string walletAddress PK
        string username
        string avatarCID
    }
    POST {
        string id PK
        string content
        string author FK
        datetime createdAt
        string emotionType
        boolean isAR
        string arContentCID
    }
    INTERACTION {
        string id PK
        string postId FK
        string userId FK
        string type
        datetime createdAt
    }
```

## Security Architecture

### Authentication
- Wallet-to-server message signing
- JWT token expiration (1 hour)
- Refresh token rotation
- Rate limiting (100 requests/min)

### Data Protection
- IPFS content encryption
- Private post end-to-end encryption
- Secure wallet key storage
- TLS 1.3 for all communications

### Smart Contract Security
- OpenZeppelin standards
- Comprehensive unit tests
- Formal verification
- Multi-sig for upgrades

### Monitoring
- Anomaly detection
- Suspicious activity alerts
- Blockchain transaction monitoring
- Regular security audits

## Scaling Strategies

### Horizontal Scaling
- API service replication
- Read replicas for databases
- CDN for static assets
- Sharded blockchain nodes

### Performance Optimization
- AR content LOD (Level of Detail)
- AI response caching
- Feed pre-generation
- WebSockets for real-time updates

### Cost Management
- Layer 2 blockchain solutions
- AI model quantization
- Storage tiering (hot/cold)
- Spot instances for non-critical services
