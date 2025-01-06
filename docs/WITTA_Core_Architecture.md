
# WITTA Core: Detailed Architecture

## Key Features and Responsibilities

1. **Task Management:**
   - Coordinate various system activities such as proposal generation, data retrieval, trading, and decision-making.
   - Queue and prioritize tasks based on urgency and importance.

2. **API Integrations:**
   - Interact with external APIs (e.g., OpenAI, Robinhood, SyncSwap) to fetch data or perform actions.
   - Handle authentication and rate limits for API calls.

3. **Data Management:**
   - Interface with the database for persistent storage (PostgreSQL).
   - Use Redis for session-based caching.
   - Leverage a vector database (e.g., ChromaDB) for memory and context storage.

4. **User Interaction:**
   - Provide a RESTful API (via Flask or FastAPI) for user interactions such as creating proposals, retrieving data, or executing commands.

5. **Scalability:**
   - Modular design to scale individual components (e.g., vector database, web server).
   - Ability to spawn additional Docker containers when needed.

6. **Monitoring and Error Handling:**
   - Log all actions for auditing and debugging.
   - Monitor resource usage and handle errors gracefully.

---

## Component Breakdown

### 1. Core Modules
The WITTA Core will consist of several functional modules:

#### Task Orchestrator
- **Purpose:** Manage tasks and workflows within the system.
- **Responsibilities:**
  - Maintain a task queue.
  - Assign tasks to specific modules or containers.
  - Track task status and dependencies.

#### API Manager
- **Purpose:** Centralize API interactions for all external services.
- **Responsibilities:**
  - Authenticate and interact with APIs.
  - Implement rate-limiting logic.
  - Support multiple APIs (e.g., OpenAI, Robinhood, SyncSwap).

#### Data Manager
- **Purpose:** Handle data storage, retrieval, and caching.
- **Responsibilities:**
  - Interface with PostgreSQL for persistent storage.
  - Use Redis for session data and caching.
  - Integrate with the vector database for memory management.

#### User Interaction Manager
- **Purpose:** Expose a RESTful API or web interface for users.
- **Responsibilities:**
  - Handle user requests (e.g., creating proposals, viewing data).
  - Provide feedback and results via the web API.

#### Logging and Monitoring
- **Purpose:** Ensure system health and debugging.
- **Responsibilities:**
  - Log all actions and events.
  - Track resource usage and performance metrics.
  - Provide alerts for failures or anomalies.

---

## External Dependencies

The WITTA Core relies on several external tools and APIs:
- **PostgreSQL:** Persistent storage for proposals, trading data, etc.
- **Redis:** Cache for frequently accessed or temporary data.
- **ChromaDB/Pinecone:** Vector database for semantic search and memory retrieval.
- **External APIs:** 
  - OpenAI for natural language tasks.
  - Robinhood for trading.
  - SyncSwap for DeFi data.

---

## Detailed Flow

### Task Execution Flow
1. User sends a request via the RESTful API (e.g., "Generate a governance proposal").
2. The **Task Orchestrator** queues the request.
3. The **API Manager** communicates with the relevant external API (e.g., OpenAI) to fulfill the task.
4. The result is stored in the **PostgreSQL database**.
5. A response is sent back to the user.

---

## Proposed File Structure

### Directory Layout
```
witta-core/
│
├── app/
│   ├── __init__.py          # Application initialization
│   ├── api/
│   │   ├── __init__.py      # API package
│   │   ├── endpoints.py     # User interaction endpoints
│   ├── core/
│   │   ├── __init__.py      # Core logic package
│   │   ├── orchestrator.py  # Task management
│   │   ├── api_manager.py   # API integrations
│   │   ├── data_manager.py  # Data storage and retrieval
│   ├── utils/
│   │   ├── logger.py        # Logging utilities
│   │   ├── config.py        # Configuration loader
│
├── tests/
│   ├── test_api.py          # API tests
│   ├── test_core.py         # Core module tests
│
├── Dockerfile               # Docker container setup
├── requirements.txt         # Python dependencies
└── README.md                # Documentation
```

---

## Development Roadmap

### Phase 1: Core Setup
- Implement the directory structure.
- Create a minimal `orchestrator.py` to queue and execute tasks.
- Build a RESTful API using FastAPI or Flask.

### Phase 2: API Integrations
- Integrate OpenAI for natural language tasks.
- Add Robinhood API for crypto trading data.

### Phase 3: Data Management
- Set up PostgreSQL and Redis.
- Integrate ChromaDB for vector-based memory retrieval.

### Phase 4: Monitoring and Logging
- Add Prometheus for resource monitoring.
- Implement structured logging using `logger.py`.

---
