# Multi-Tenancy Demo with Dynamic Database Connections

This demo showcases how to implement **multi-database multi-tenancy** using RAD Server Resource Interceptors. This is an alternative to RAD Server's built-in multi-tenancy solution. While the built-in approach uses a single database with tenant_id columns, this demo illustrates how interceptors can be used to connect to separate databases for each tenant.

## What This Demo Demonstrates

### Key Concepts
- **Dynamic Database Connection**: The interceptor connects to different databases based on the tenant identifier in each request
- **Physical Data Isolation**: Each tenant's data is stored in a completely separate database file
- **Flexible Schema**: Different tenants could potentially have different schemas (not shown in this simple demo)
- **Interceptor Pattern**: All database connection logic is centralized in `BeforeRequest`, keeping endpoint code clean

### Comparison with Built-in RAD Server Multi-Tenancy

Both approaches are valid depending on your requirements. Here's how they differ:

| Feature | Built-in Multi-Tenancy | This Demo (Interceptor-Based) |
|---------|----------------------|-------------------------------|
| Database Architecture | Single shared database | Separate database per tenant |
| Data Isolation | Logical (tenant_id column) | Physical (separate DB files) |
| Schema Flexibility | All tenants share schema | Each tenant can have unique schema |
| Implementation | Built-in, ready to use | Custom implementation required |
| Tenant Provisioning | Add data with tenant_id | Create new database file |
| Maintenance | Single database to manage | Multiple databases to manage |

**Note:** The built-in multi-tenancy solution is excellent for many scenarios and requires less custom code. This demo simply illustrates an alternative pattern that may be useful when physical database separation is required.

## Project Structure

```
multi-tenancy/
├── Resource.Products.pas      # Main resource with interceptor implementation
├── Resource.Products.dfm      # DataModule with FireDAC components
├── Multitentancy.dproj        # RAD Server package project
├── Data/                      # InterBase database files (pre-populated)
│   ├── tenant1.ib            # Electronics store (8 products)
│   ├── tenant2.ib            # Clothing store (10 products)
│   └── tenant3.ib            # Grocery store (12 products)
├── test_api.bat              # Script to test all endpoints
└── README.md                 # This file
```

## Setup Instructions

### Step 1: InterBase Server Setup

Ensure InterBase is installed and running on `localhost:3050` with default credentials (`SYSDBA` / `masterkey`). The demo includes three pre-populated databases in the `Data` folder.

### Step 2: Configure the Base Path

**IMPORTANT**: Before compiling, you must update the `BASE_PATH` constant in `Resource.Products.pas` to match your project location.

```pascal
const
  // *** CHANGE THIS PATH TO YOUR PROJECT LOCATION ***
  BASE_PATH = 'C:\Your\Path\To\multi-tenancy\';
```

This is required because RAD Server packages run as BPLs and cannot use relative paths. The path should point to the folder containing the `Data` directory.

### Step 3: Compile and Run the Package

1. Open `Multitentancy.dproj` in RAD Studio
2. Run the project (Project → Build)

### Step 3: Test the API

Run the test script:
```batch
test_api.bat
```

Or test manually with curl:
```bash
# Get all products from tenant1 (Electronics) - use -i to see headers
curl -i -X GET http://localhost:8080/products/ -H "X-Tenant-ID: tenant1"

# Get all products from tenant2 (Clothing)
curl -i -X GET http://localhost:8080/products/ -H "X-Tenant-ID: tenant2"

# Get specific product from tenant3 (Grocery)
curl -i -X GET http://localhost:8080/products/1 -H "X-Tenant-ID: tenant3"
```

## API Reference

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

### Endpoints

#### GET /products/
Get all products for the specified tenant.

**Headers:**
- `X-Tenant-ID`: The tenant identifier (tenant1, tenant2, or tenant3)

**Query Parameters (Optional):**
- `page`: Page number, `psize`: Page size (default: 50, max: 1000)
- `sf<fieldname>`: Sorting - A (ascending) or D (descending). Example: `sfname=A&sfprice=D`

**Response (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Laptop Pro 15\"",
    "description": "High-performance laptop with 16GB RAM and 512GB SSD",
    "price": 1299.99,
    "stock": 15
  },
  ...
]
```

**Response Headers (Added by Interceptor):**
```
X-Tenant-ID: tenant1
X-Page: 1
X-Page-Size: 50
X-Sorting: name:ASC
```

**Note:** The interceptor adds metadata via HTTP headers without modifying the response body.

**Examples:**
```bash
# Pagination
curl -i "http://localhost:8080/products/?page=1&psize=5" -H "X-Tenant-ID: tenant1"

# Sorting and pagination combined
curl -i "http://localhost:8080/products/?page=1&psize=3&sfprice=A" -H "X-Tenant-ID: tenant1"
```

#### GET /products/{id}
Get a specific product by ID for the specified tenant.

**Headers:**
- `X-Tenant-ID`: The tenant identifier

**Response (200 OK):**
```json
{
  "id": 1,
  "name": "Laptop Pro 15\"",
  "description": "High-performance laptop with 16GB RAM and 512GB SSD",
  "price": 1299.99,
  "stock": 15
}
```


## Implementation Details

### How the Interceptor Works

```pascal
// 1. BeforeRequest: Extract tenant ID and connect to database
procedure TProductsResource1.BeforeRequest(...);
begin
  // Extract tenant from header or query param
  FTenantID := ExtractTenantID(ARequest);
  
  // Validate tenant exists
  if GetDatabasePath(FTenantID) = '' then
    // Return error, set AHandled := True
  
  // Connect to tenant's database
  if not ConnectToTenantDatabase(FTenantID) then
    // Return error, set AHandled := True
end;

// 2. TEMSDataSetResource executes with correct database connection
//    (Provides automatic CRUD operations)

// 3. AfterRequest: Add metadata via headers and cleanup
procedure TProductsResource1.AfterRequest(...);
begin
  DisconnectDatabase;
  
  // Add HTTP headers with tenant and pagination info
  // This approach is non-intrusive and works with all response formats
  AResponse.Headers.SetValue('X-Tenant-ID', FTenantID);
  AResponse.Headers.SetValue('X-Page', ...);
  AResponse.Headers.SetValue('X-Page-Size', ...);
  AResponse.Headers.SetValue('X-Sorting', ...);
end;
```

### Response Headers

The interceptor adds metadata via HTTP headers: `X-Tenant-ID` (always), `X-Page`, `X-Page-Size`, `X-Sorting` (when applicable). This approach is non-intrusive and works with all response formats.

### TEMSDataSetResource

This demo uses `TEMSDataSetResource` which provides automatic CRUD operations, built-in pagination/sorting, and multiple response formats (JSON, CSV, BSON, FireDAC formats).

**Configuration:**
```pascal
EMSDataSetResource.DataSet := FDQProducts;
EMSDataSetResource.KeyFields := 'id';
EMSDataSetResource.Options := [roEnableParams, roEnablePaging, roEnablePageSizing, 
                                roEnableSorting, roReturnNewEntityKey, roAppendOnPut];
```

**Note:** `roEnablePageSizing` is required for the `psize` URL parameter to work.

### Database Configuration

The demo includes three pre-configured tenants (tenant1: Electronics, tenant2: Clothing, tenant3: Grocery). Connection details: InterBase on `localhost:3050`, credentials `SYSDBA`/`masterkey`.

**Note:** Tenant mappings are hardcoded in `GetDatabasePath()` for demo purposes. Production systems should use a configuration database, file, or service.

### Adding New Tenants

To add a new tenant to this demo:

1. Create a new InterBase database file (e.g., `Data\tenant4.ib`)
   ```sql
   CREATE DATABASE 'C:\Path\To\Data\tenant4.ib'
   USER 'SYSDBA' PASSWORD 'masterkey'
   PAGE_SIZE 8192 DEFAULT CHARACTER SET UTF8;
   ```

2. Create the products table schema:
   ```sql
   CREATE TABLE products (
     id INTEGER NOT NULL PRIMARY KEY,
     name VARCHAR(100) NOT NULL,
     description VARCHAR(500),
     price DECIMAL(10,2) NOT NULL,
     stock INTEGER NOT NULL
   );
   ```

3. Add the tenant mapping in `GetDatabasePath()`:
   ```pascal
   else if ATenantID = 'tenant4' then
     Result := BASE_PATH + 'Data\tenant4.ib'
   ```

4. Populate the database with your data

## Production Considerations

### Tenant Configuration Management

Replace hardcoded tenant mappings with one of these approaches:
- **Configuration Database**: Store tenant config in a central database table
- **Configuration File**: JSON/XML file loaded at startup with caching
- **Configuration Service**: Consul, etcd, or cloud-native config services
- **Environment Variables**: For containerized deployments

### Performance Optimization
- **Connection Pooling**: Instead of connecting/disconnecting per request, use a connection pool keyed by tenant ID
- **Configuration Caching**: Cache tenant configuration in memory (with TTL and invalidation strategy)
- **Prepared Statements**: Use parameterized queries (already done via TEMSDataSetResource)
- **Lazy Loading**: Only load tenant configuration when first accessed

### Security
- **Tenant Isolation**: Validate that users can only access their authorized tenants
- **SQL Injection**: Use parameters for all queries (already done via TEMSDataSetResource)
- **Authentication**: Add proper authentication to validate tenant credentials
- **Database Credentials**: Store database passwords securely (not hardcoded)

### Scalability
- **Database Sharding**: Distribute tenants across multiple database servers
- **Load Balancing**: Route tenant requests to appropriate database servers
- **Dynamic Tenant Onboarding**: Automated tenant provisioning via API
- **Tenant Migration**: Tools and procedures for moving tenants between servers

### Monitoring
- **Logging**: Add comprehensive logging of tenant access and database operations
- **Metrics**: Track per-tenant usage, performance, and errors
- **Alerting**: Set up alerts for connection failures or unusual patterns
- **Connection Tracking**: Monitor active connections per tenant to prevent resource exhaustion

## Characteristics of This Approach

**What This Pattern Provides:**
- **Physical Data Isolation**: Each tenant's data is in a separate database file
- **Schema Independence**: Tenants can potentially have different database schemas
- **Database Portability**: Individual tenant databases can be moved or backed up independently
- **Distributed Architecture**: Tenants can be hosted on different database servers
- **Interceptor Pattern**: Connection logic is centralized in BeforeRequest/AfterRequest

**Trade-offs to Consider:**
- Requires custom code (vs. built-in solution which is ready to use)
- More databases to manage and maintain
- Connection overhead per request (can be mitigated with connection pooling)
- More complex deployment compared to single-database approach  

## Troubleshooting

### "Database not found" Error
- Verify the `Data` folder exists with the `.ib` database files
- Check that `BASE_PATH` constant is set correctly in `Resource.Products.pas`
- Ensure database files have read/write permissions
- Verify the path uses absolute paths (not relative)

### Connection Failures
- Verify InterBase server is running on `localhost:3050` with correct credentials
- Check database files are accessible and not corrupted
- Verify FireDAC InterBase driver is configured
- Check firewall settings for port 3050
- Review InterBase error log for details

### BPL Loading Issues
- Verify absolute paths are used in `BASE_PATH` (not relative)
- Check that RAD Server service account has permissions to access the database path
- Ensure proper permissions on `Data` folder
- Verify InterBase client libraries are accessible to RAD Server

### "Tenant not found" Errors
- Verify tenant ID matches exactly (case-sensitive): `tenant1`, `tenant2`, `tenant3`
- Check `GetDatabasePath()` function has correct tenant mappings
- Ensure `X-Tenant-ID` header or `tenant` query parameter is provided

## License

This demo is part of the RAD Server documentation project.

## Related Demos

- **Basic Demo**: Simple interceptor implementation
- **Advanced Demo**: Base class pattern with inheritance

See the parent README for more information about the Resource Interceptor series.
