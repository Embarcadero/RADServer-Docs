# Extending RAD Server with Resource Interceptors

Don't forget to [watch the video](https://youtu.be/ehy_HiE6CBs) of this chapter. 

This project demonstrates how to implement the `IEMSResourceInterceptor` interface in RAD Server to add cross-cutting concerns like logging, authentication, validation, and response enhancement to your API endpoints.

## Overview

Resource Interceptors allow you to intercept requests and responses at the resource level, providing a powerful way to implement common functionality across multiple endpoints without code duplication. This project includes three demonstration approaches:

1. **Basic Demo** - Simple implementation directly in a resource
2. **Advanced Demo** - Reusable base class pattern with inheritance
3. **Multi-Tenancy Demo** - Dynamic database connections for multi-tenant applications

## Project Structure

```
18 - Extending RAD Server with Resource Interceptors/
├── C++/
│   ├── basic/                    # Basic interceptor implementation
│   │   ├── Interceptor.cbproj
│   │   ├── ResourceDemo.cpp
│   │   └── test_api.bat
│   ├── advanced/                 # Advanced inheritance pattern
│   │   ├── InterceptorAdvanced.cbproj
│   │   ├── BaseInterceptor.cpp
│   │   ├── ResourceSimpleDemo.cpp
│   │   ├── ResourceAdminDemo.cpp
│   │   └── test_api.bat
└── Delphi/
    ├── basic/                    # Basic interceptor implementation
    │   ├── Interceptor.dproj
    │   ├── Resource.Demo.pas
    │   └── test_api.bat
    ├── advanced/                 # Advanced inheritance pattern
    │   ├── InterceptorAdvanced.dproj
    │   ├── BaseInterceptor.pas
    │   ├── Resource.SimpleDemo.pas
    │   ├── Resource.AdminDemo.pas
    │   └── test_api.bat
    └── multi-tenancy/            # Multi-tenant database connections
        ├── Multitentancy.dproj
        ├── Resource.Products.pas
        ├── Data/                 # InterBase database files
        └── test_api.bat
```

## Basic Demo

### What It Demonstrates

The basic demo shows the simplest way to implement `IEMSResourceInterceptor` by implementing the interface directly in a single resource class.

**Key Features:**
- Direct interface implementation in resource class
- Request tracking with unique IDs
- Automatic logging of request start/completion
- Response metadata injection
- Basic JSON validation for POST requests
- Browser-accessible endpoints (no authentication)

### Implementation Pattern

```pascal
[ResourceName('demo')]
TDemoResource1 = class(TDataModule, IEMSResourceInterceptor)
  // Implements IEMSResourceInterceptor directly
  // No inheritance, no authentication, no complex features
end;
```

### API Endpoints

#### GET /demo/hello
Returns a hello message with metadata.

**Response:**
```json
{
  "data": {
    "message": "Hello from demo interceptor!"
  },
  "meta": {
    "request_id": "20251201-143022-1234",
    "timestamp": "2025-12-01 14:30:22",
    "duration_ms": 15
  }
}
```

#### POST /demo/echo
Echoes back the message from the request body.

**Request:**
```json
{
  "message": "Hello World"
}
```

**Response:**
```json
{
  "data": {
    "echo": "Hello World"
  },
  "meta": {
    "request_id": "20251201-143022-5678",
    "timestamp": "2025-12-01 14:30:22",
    "duration_ms": 12
  }
}
```

### Testing

**Browser Testing:**
```
http://localhost:8080/demo/hello
```

**Command Line Testing:**
```bash
# Run the test script
test_api.bat

# Manual testing
curl -X GET http://localhost:8080/demo/hello
curl -X POST http://localhost:8080/demo/echo \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello World"}'
```

## Advanced Demo

### What It Demonstrates

The advanced demo shows a more sophisticated approach using inheritance patterns to create reusable, extensible interceptor functionality.

**Key Features:**
- Base class implementing `IEMSResourceInterceptor`
- Inheritance pattern for multiple resources
- Custom authentication system
- Virtual methods for customization
- Proper encapsulation and access control
- Safe header access and error handling

### Architecture Pattern

```pascal
// Base class implements the interface
TBaseInterceptor = class(TInterfacedPersistent, IEMSResourceInterceptor)
  // Common functionality for all resources
end;

// Resources inherit from the base class
TSimpleDemoResource = class(TBaseInterceptor)
  // Resource-specific logic
end;

TAdminDemoResource = class(TBaseInterceptor)
  // Admin-specific logic with custom authentication
end;
```

### Key Implementation Details

#### 1. Interface Implementation
The `IEMSResourceInterceptor` interface requires two methods:
```pascal
procedure BeforeRequest(const AContext: TEndpointContext;
  const ARequest: TEndpointRequest; const AResponse: TEndpointResponse;
  var AHandled: Boolean);
procedure AfterRequest(const AContext: TEndpointContext;
  const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
```

#### 2. Virtual Methods for Customization
The base class provides virtual methods that descendants can override:
```pascal
protected
  procedure DoCustomAuthentication(...); virtual;
  procedure DoCustomValidation(...); virtual;
  procedure DoCustomLogging(...); virtual;
```

#### 3. Custom Authentication
Uses a custom header to avoid conflicts with RAD Server's built-in authentication:
```bash
X-Custom-Token: your-token-here
```

### API Endpoints

#### Simple Demo Endpoints
- **GET /demo/hello** - Hello message (requires authentication)
- **POST /demo/echo** - Echo service (requires authentication + JSON validation)

#### Admin Demo Endpoints  
- **GET /admin/status** - Admin-only status endpoint (requires admin token)

### Testing

**Important:** Manual testing will NOT work because this project uses custom authentication headers. You must use the provided test script.

```bash
# Run the comprehensive test suite
test_api.bat
```

The test script demonstrates:
- ✅ Authentication success/failure scenarios
- ✅ JSON validation
- ✅ Admin access control
- ✅ Content-Type validation
- ✅ Error handling

**Expected Test Results:**
1. **Authentication failure** (401) - No token provided
2. **Authentication success** (200) - Valid token accepted
3. **POST validation** (201) - Valid JSON with required fields
4. **Validation failure** (400) - Missing required fields
5. **Admin access denied** (401) - Regular token for admin endpoint
6. **Admin access granted** (200) - Admin token for admin endpoint
7. **Content type validation** (400) - Wrong content type

## Multi-Tenancy Demo

### What It Demonstrates

The multi-tenancy demo showcases how to implement **multi-database multi-tenancy** using Resource Interceptors. This is an alternative to RAD Server's built-in multi-tenancy solution, demonstrating how interceptors can dynamically connect to separate databases for each tenant based on request headers or query parameters.

**Key Features:**
- Dynamic database connection switching per tenant
- Physical data isolation (separate database files per tenant)
- Tenant identification via HTTP headers or query parameters
- Automatic CRUD operations using `TEMSDataSetResource`
- Built-in pagination and sorting support
- Non-intrusive metadata injection via HTTP headers

### Comparison with Built-in Multi-Tenancy

| Feature | Built-in Multi-Tenancy | This Demo (Interceptor-Based) |
|---------|----------------------|-------------------------------|
| Database Architecture | Single shared database | Separate database per tenant |
| Data Isolation | Logical (tenant_id column) | Physical (separate DB files) |
| Schema Flexibility | All tenants share schema | Each tenant can have unique schema |
| Implementation | Built-in, ready to use | Custom implementation required |
| Tenant Provisioning | Add data with tenant_id | Create new database file |

**Note:** The built-in multi-tenancy solution is excellent for many scenarios. This demo illustrates an alternative pattern useful when physical database separation is required.

### Implementation Pattern

```pascal
[ResourceName('products')]
TProductsResource1 = class(TDataModule, IEMSResourceInterceptor)
  // BeforeRequest: Extract tenant ID and connect to tenant's database
  // AfterRequest: Disconnect and add metadata headers
end;
```

### Tenant Identification

The API supports two methods for tenant identification:

1. **HTTP Header** (Recommended):
   ```
   X-Tenant-ID: tenant1
   ```

2. **Query Parameter** (Browser-friendly fallback):
   ```
   ?tenant=tenant1
   ```

### API Endpoints

#### GET /products/
Get all products for the specified tenant with optional pagination and sorting.

**Headers:**
- `X-Tenant-ID`: The tenant identifier (tenant1, tenant2, or tenant3)

**Query Parameters (Optional):**
- `page`: Page number
- `psize`: Page size (default: 50, max: 1000)
- `sf<fieldname>`: Sorting - A (ascending) or D (descending). Example: `sfname=A&sfprice=D`

**Response Headers (Added by Interceptor):**
```
X-Tenant-ID: tenant1
X-Page: 1
X-Page-Size: 50
X-Sorting: name:ASC
```

#### GET /products/{id}
Get a specific product by ID for the specified tenant.

### Setup Requirements

1. **InterBase Server**: Must be running on `localhost:3050` with credentials `SYSDBA`/`masterkey`
2. **Database Files**: Three pre-populated databases in the `Data` folder (tenant1.ib, tenant2.ib, tenant3.ib)
3. **Path Configuration**: Update the `BASE_PATH` constant in the resource file to match your project location

### Testing

```bash
# Run the comprehensive test suite
test_api.bat

# Manual testing examples
curl -i -X GET http://localhost:8080/products/ -H "X-Tenant-ID: tenant1"
curl -i "http://localhost:8080/products/?page=1&psize=5" -H "X-Tenant-ID: tenant1"
curl -i -X GET http://localhost:8080/products/1 -H "X-Tenant-ID: tenant3"
```

### Key Implementation Details

- **BeforeRequest**: Extracts tenant ID, validates tenant exists, and connects to the tenant's database
- **AfterRequest**: Disconnects from database and adds metadata via HTTP headers
- **TEMSDataSetResource**: Provides automatic CRUD operations with built-in pagination and sorting
- **Response Headers**: Metadata is added via headers without modifying response body

For complete documentation, setup instructions, and production considerations, see the detailed README files in:
- `Delphi/multi-tenancy/README.md` (comprehensive documentation)
- `C++/multi-tenancy/README.md` (C++-specific details)

## Extending the Projects

To add a new resource with interceptor behavior:

### Basic Pattern
```pascal
[ResourceName('myapi')]
TMyNewResource = class(TDataModule, IEMSResourceInterceptor)
  // Implement IEMSResourceInterceptor methods directly
end;
```

### Advanced Pattern
```pascal
[ResourceName('myapi')]
TMyNewResource = class(TBaseInterceptor)
protected
  procedure DoCustomValidation(const ARequest: TEndpointRequest; 
    var AValid: Boolean; var AErrorMessage: string); override;
published
  [ResourceSuffix('data')]
  procedure GetData(const AContext: TEndpointContext; 
    const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
end;
```