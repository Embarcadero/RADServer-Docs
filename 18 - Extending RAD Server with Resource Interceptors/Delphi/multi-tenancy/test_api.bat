@echo off
REM ============================================================================
REM Multi-Tenancy Demo - API Test Script
REM ============================================================================
REM
REM This script tests the multi-tenancy interceptor functionality
REM Make sure RAD Server is running before executing this script
REM
REM Expected: Each tenant should return different products from their database
REM ============================================================================

echo.
echo ============================================================================
echo Multi-Tenancy Demo - Testing Dynamic Database Connections
echo ============================================================================
echo.
echo Prerequisites:
echo - RAD Server must be running on localhost:8080
echo - All three InterBase databases must be created (tenant1.ib, tenant2.ib, tenant3.ib)
echo - Update BASE_PATH in Resource.Products.pas to match your installation
echo - InterBase server must be running on localhost:3050
echo.

REM Test 1: Tenant 1 - Electronics Store
echo.
echo ============================================================================
echo Test 1: Tenant 1 - Electronics Store (GET all products)
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/
echo Header: X-Tenant-ID: tenant1
echo Expected Header: X-Tenant-ID: tenant1
echo.
curl -i -X GET "http://localhost:8080/products/" -H "X-Tenant-ID: tenant1"
echo.

REM Test 2: Tenant 2 - Clothing Store
echo.
echo ============================================================================
echo Test 2: Tenant 2 - Clothing Store (GET all products)
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/
echo Header: X-Tenant-ID: tenant2
echo Expected Header: X-Tenant-ID: tenant2
echo.
curl -i -X GET "http://localhost:8080/products/" -H "X-Tenant-ID: tenant2"
echo.

REM Test 3: Tenant 3 - Grocery Store
echo.
echo ============================================================================
echo Test 3: Tenant 3 - Grocery Store (GET all products)
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/
echo Header: X-Tenant-ID: tenant3
echo Expected Header: X-Tenant-ID: tenant3
echo.
curl -i -X GET "http://localhost:8080/products/" -H "X-Tenant-ID: tenant3"
echo.

REM Test 4: Get specific product from Tenant 1
echo.
echo ============================================================================
echo Test 4: Get specific product (ID=1) from Tenant 1
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/1
echo Header: X-Tenant-ID: tenant1
echo Expected Header: X-Tenant-ID: tenant1
echo.
curl -i -X GET "http://localhost:8080/products/1" -H "X-Tenant-ID: tenant1"
echo.

REM Test 5: Get specific product from Tenant 2
echo.
echo ============================================================================
echo Test 5: Get specific product (ID=3) from Tenant 2
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/3
echo Header: X-Tenant-ID: tenant2
echo Expected Header: X-Tenant-ID: tenant2
echo.
curl -i -X GET "http://localhost:8080/products/3" -H "X-Tenant-ID: tenant2"
echo.

REM Test 6: Get specific product from Tenant 3
echo.
echo ============================================================================
echo Test 6: Get specific product (ID=5) from Tenant 3
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/5
echo Header: X-Tenant-ID: tenant3
echo Expected Header: X-Tenant-ID: tenant3
echo.
curl -i -X GET "http://localhost:8080/products/5" -H "X-Tenant-ID: tenant3"
echo.

REM Test 7: Missing tenant ID (should fail with 400)
echo.
echo ============================================================================
echo Test 7: Missing tenant ID (should return 400 error)
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/
echo Header: (none)
echo Expected: 400 Bad Request (no X-Tenant-ID header)
echo.
curl -i -X GET "http://localhost:8080/products/"
echo.

REM Test 8: Invalid tenant ID (should fail with 404)
echo.
echo ============================================================================
echo Test 8: Invalid tenant ID (should return 404 error)
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/
echo Header: X-Tenant-ID: invalid_tenant
echo Expected: 404 Not Found (no X-Tenant-ID header for errors)
echo.
curl -i -X GET "http://localhost:8080/products/" -H "X-Tenant-ID: invalid_tenant"
echo.

REM Test 9: Browser-friendly query parameter (fallback method)
echo.
echo ============================================================================
echo Test 9: Using query parameter instead of header (browser-friendly)
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/?tenant=tenant1
echo Header: (none - using query param instead)
echo Expected Header: X-Tenant-ID: tenant1
echo.
curl -i -X GET "http://localhost:8080/products/?tenant=tenant1"
echo.

REM Test 10: Product not found in tenant
echo.
echo ============================================================================
echo Test 10: Product ID that doesn't exist (should return 404)
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/9999
echo Header: X-Tenant-ID: tenant1
echo Expected: 404 Not Found (no X-Tenant-ID header for errors)
echo.
curl -i -X GET "http://localhost:8080/products/9999" -H "X-Tenant-ID: tenant1"
echo.

REM Test 11: Pagination - First page
echo.
echo ============================================================================
echo Test 11: Pagination - First page (5 items per page)
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/?page=1^&psize=5
echo Header: X-Tenant-ID: tenant1
echo Expected Headers: X-Page: 1, X-Page-Size: 5
echo.
curl -i -X GET "http://localhost:8080/products/?page=1&psize=5" -H "X-Tenant-ID: tenant1"
echo.

REM Test 12: Pagination - Second page
echo.
echo ============================================================================
echo Test 12: Pagination - Second page (5 items per page)
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/?page=2^&psize=5
echo Header: X-Tenant-ID: tenant3
echo Expected Headers: X-Page: 2, X-Page-Size: 5
echo.
curl -i -X GET "http://localhost:8080/products/?page=2&psize=5" -H "X-Tenant-ID: tenant3"
echo.

REM Test 13: Sorting - By name ascending
echo.
echo ============================================================================
echo Test 13: Sorting - By name ascending
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/?sfname=A
echo Header: X-Tenant-ID: tenant3
echo Expected Header: X-Sorting: name:ASC
echo.
curl -i -X GET "http://localhost:8080/products/?sfname=A" -H "X-Tenant-ID: tenant3"
echo.

REM Test 14: Sorting - By price descending
echo.
echo ============================================================================
echo Test 14: Sorting - By price descending
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/?sfprice=D
echo Header: X-Tenant-ID: tenant1
echo Expected Header: X-Sorting: price:DESC
echo.
curl -i -X GET "http://localhost:8080/products/?sfprice=D" -H "X-Tenant-ID: tenant1"
echo.

REM Test 15: Combined - Pagination + Sorting
echo.
echo ============================================================================
echo Test 15: Combined - Pagination + Sorting
echo ============================================================================
echo Endpoint: GET http://localhost:8080/products/?page=1^&psize=3^&sfprice=A
echo Header: X-Tenant-ID: tenant3
echo Expected Headers: X-Page: 1, X-Page-Size: 3, X-Sorting: price:ASC
echo.
curl -i -X GET "http://localhost:8080/products/?page=1&psize=3&sfprice=A" -H "X-Tenant-ID: tenant3"
echo.

echo.
echo ============================================================================
echo Testing Complete!
echo ============================================================================
echo.
echo Summary:
echo - Tests 1-6: Should return different products for each tenant
echo - Test 7: Should show error (missing tenant identifier)
echo - Test 8: Should show error (unknown tenant)
echo - Test 9: Should work (query parameter fallback)
echo - Test 10: Should show error (product not found)
echo - Test 11-12: Pagination - Demonstrating paging through results
echo - Test 13-14: Sorting - Demonstrating field sorting (ASC/DESC)
echo - Test 15: Combined - Pagination + Sorting together
echo.
echo Key Points:
echo - Each tenant has its own isolated database
echo - The interceptor dynamically connects to the correct database
echo - Data is physically separated between tenants
echo - Pagination and sorting work with TEMSDataSetResource
echo - Metadata added via HTTP headers (non-intrusive approach)
echo - Headers show: X-Tenant-ID, X-Page, X-Page-Size, X-Sorting
echo - Response body remains clean and unmodified
echo.
echo Note: All tests use -i flag to show complete HTTP response with headers
echo.
echo Expected Results:
echo - Tests 1-6, 9: Should show X-Tenant-ID header
echo - Tests 7-8, 10: Error responses (no X-Tenant-ID on errors)
echo - Tests 11-15: Should show X-Tenant-ID + pagination/sorting headers
echo.
pause
