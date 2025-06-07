# Handle Resolution & Formatting Flow Diagram

```mermaid
graph TB
    subgraph "AT Protocol Handle Resolution"
        A[User Handle<br/>alice.example.com] --> B{Resolution Method}
        
        B -->|DNS| C[Query TXT Record<br/>_atproto.alice.example.com]
        B -->|HTTPS| D[Fetch<br/>https://alice.example.com/.well-known/atproto-did]
        
        C --> E[Extract DID<br/>did:plc:abc123...]
        D --> E
        
        E --> F[Fetch DID Document<br/>from PLC Registry]
        
        F --> G{Verify Bidirectional<br/>Binding}
        G -->|Valid| H[✓ Verified Handle]
        G -->|Invalid| I[✗ Rejected]
    end
    
    subgraph "Our Handle Formatting System"
        H --> J[Handle Formatter]
        
        J --> K{Display Mode}
        
        K -->|Smart| L[Analyze Domain]
        L --> M{Custom Domain?}
        M -->|Yes| N[Preserve Full Handle<br/>@alice.example.com]
        M -->|No| O[Remove Suffix<br/>@alice]
        
        K -->|Hide Common| P[Remove .bsky.* only<br/>@alice]
        K -->|Hide All| Q[Remove all TLDs<br/>@alice]
        K -->|Full| R[Show Complete<br/>@alice.example.com]
        
        N --> S[Display in UI]
        O --> S
        P --> S
        Q --> S
        R --> S
    end
    
    style A fill:#e1f5fe
    style H fill:#c8e6c9
    style I fill:#ffcdd2
    style S fill:#fff9c4
```

## Handle Formatting Decision Tree

```mermaid
graph TD
    A[Input Handle] --> B{Is it a valid handle?}
    
    B -->|No| C[Return as-is]
    B -->|Yes| D{Check Display Mode}
    
    D -->|Smart Mode| E{Is Verified Account?}
    E -->|Yes + Show Verified| F[Keep Full Handle]
    E -->|No| G{Has Custom Domain?}
    
    G -->|Yes| H[Keep Full Handle]
    G -->|No| I{Has Common Suffix?}
    
    I -->|Yes| J[Remove Suffix]
    I -->|No| K[Keep as-is]
    
    D -->|Hide Common| L{Has .bsky.* suffix?}
    L -->|Yes| M[Remove Suffix]
    L -->|No| N[Keep as-is]
    
    D -->|Hide All| O{Has Known TLD?}
    O -->|Yes| P[Remove TLD]
    O -->|No| Q[Keep as-is]
    
    D -->|Full| R[Keep Full Handle]
    
    F --> S{Needs Truncation?}
    H --> S
    J --> S
    K --> S
    M --> S
    N --> S
    P --> S
    Q --> S
    R --> S
    
    S -->|Yes| T[Truncate with ...]
    S -->|No| U[Final Output]
    T --> U
    
    style A fill:#e3f2fd
    style U fill:#f3e5f5
```

## Domain Verification Methods Comparison

| Method | DNS TXT Record | HTTPS Well-Known |
|--------|----------------|------------------|
| **Setup** | Add TXT record to DNS | Host file on web server |
| **Format** | `_atproto.handle` → `did=did:plc:xxx` | `/.well-known/atproto-did` → `did:plc:xxx` |
| **Pros** | • No web server needed<br/>• Simple for single handle<br/>• DNS provider UI | • Easy for many subdomains<br/>• Dynamic responses<br/>• No DNS access needed |
| **Cons** | • Requires DNS access<br/>• One record per handle<br/>• DNS propagation delay | • Requires web server<br/>• HTTPS certificate needed<br/>• Server maintenance |
| **Best For** | Individual users | Organizations, services |

## Handle Examples by Category

### Standard Bluesky Handles
```
alice.bsky.social     → @alice
team.bsky.team       → @team  
dev.bsky.app         → @dev
admin.bsky.network   → @admin
```

### Custom Domain Handles (Preserved)
```
news.nytimes.com     → @news.nytimes.com
support.apple.com    → @support.apple.com
blog.personal.site   → @blog.personal.site
ceo.company.io       → @ceo.company.io
```

### International Domains
```
user.co.uk          → @user.co.uk (Smart)
user.co.uk          → @user.co (Hide All)
admin.de            → @admin.de (Smart)
admin.de            → @admin (Hide All)
```

### Edge Cases
```
verylongusername.bsky.social → @verylonguserna... (Compact)
a.b.c.d.bsky.social          → @a.b.c.d
user                         → @user (no domain)
""                          → @ (empty - handled gracefully)
``` 