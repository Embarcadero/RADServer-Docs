@echo off
echo.
echo ================================================
echo   Advanced RAD Server Interceptor Demo Tests (C++)
echo ================================================
echo.

echo +-----------------------------------------------+
echo ^| [1/9] Testing authentication failure (no token)
echo ^| Expected: 401 - Missing X-Custom-Token header
echo +-----------------------------------------------+
curl -X GET http://localhost:8080/demo/hello -H "Content-Type: application/json"
echo   [OK] Test 1 completed
echo.

echo +-----------------------------------------------+
echo ^| [2/9] Testing simple authentication success
echo ^| Expected: 200 - Hello message with metadata
echo +-----------------------------------------------+
curl -X GET http://localhost:8080/demo/hello -H "Content-Type: application/json" -H "X-Custom-Token: test-token"
echo   [OK] Test 2 completed
echo.

echo +-----------------------------------------------+
echo ^| [3/9] Testing GET with metadata=false
echo ^| Expected: 200 - Hello message WITHOUT metadata
echo +-----------------------------------------------+
curl -X GET "http://localhost:8080/demo/hello?metadata=false" -H "Content-Type: application/json" -H "X-Custom-Token: test-token"
echo   [OK] Test 3 completed
echo.

echo +-----------------------------------------------+
echo ^| [4/9] Testing POST with valid JSON (should return 201 Created)
echo ^| Expected: 201 - Echo response with metadata
echo +-----------------------------------------------+
curl -X POST http://localhost:8080/demo/echo -H "Content-Type: application/json" -H "X-Custom-Token: test-token" -d "{\"message\":\"Hello World\"}"
echo   [OK] Test 4 completed
echo.

echo +-----------------------------------------------+
echo ^| [5/9] Testing POST with metadata=0
echo ^| Expected: 201 - Echo response WITHOUT metadata
echo +-----------------------------------------------+
curl -X POST "http://localhost:8080/demo/echo?metadata=0" -H "Content-Type: application/json" -H "X-Custom-Token: test-token" -d "{\"message\":\"Hello World\"}"
echo   [OK] Test 5 completed
echo.

echo +-----------------------------------------------+
echo ^| [6/9] Testing validation failure (missing required field)
echo ^| Expected: 400 - Message field is required
echo +-----------------------------------------------+
curl -X POST http://localhost:8080/demo/echo -H "Content-Type: application/json" -H "X-Custom-Token: test-token" -d "{\"other_field\":\"value\"}"
echo   [OK] Test 6 completed
echo.

echo +-----------------------------------------------+
echo ^| [7/9] Testing admin access with regular token (should fail)
echo ^| Expected: 401 - Invalid custom token
echo +-----------------------------------------------+
curl -X GET http://localhost:8080/admin/status -H "Content-Type: application/json" -H "X-Custom-Token: test-token"
echo   [OK] Test 7 completed
echo.

echo +-----------------------------------------------+
echo ^| [8/9] Testing admin access with admin token (should succeed)
echo ^| Expected: 200 - Admin status with metadata
echo +-----------------------------------------------+
curl -X GET http://localhost:8080/admin/status -H "Content-Type: application/json" -H "X-Custom-Token: admin-token"
echo   [OK] Test 8 completed
echo.

echo +-----------------------------------------------+
echo ^| [9/9] Testing content type validation failure
echo ^| Expected: 400 - Content-Type must be application/json
echo +-----------------------------------------------+
curl -X POST http://localhost:8080/demo/echo -H "Content-Type: text/plain" -H "X-Custom-Token: test-token" -d "Hello World"
echo   [OK] Test 9 completed
echo.

echo ================================================
echo            All tests completed!
echo ================================================
echo.
echo Note: Metadata is included by default. Use ?metadata=false to disable.
echo.
pause 