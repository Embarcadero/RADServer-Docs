@echo off
echo.
echo ================================================
echo   Basic RAD Server Interceptor Demo Tests
echo ================================================
echo.

echo [1/5] Testing GET /demo/hello (browser accessible)
echo Expected: 200 - Hello message with metadata (default)
echo.
curl -X GET http://localhost:8080/demo/hello
echo.
echo.

echo [2/5] Testing GET /demo/hello with metadata=true
echo Expected: 200 - Hello message with metadata
echo.
curl -X GET "http://localhost:8080/demo/hello?metadata=true"
echo.
echo.

echo [3/5] Testing GET /demo/hello with metadata=false
echo Expected: 200 - Hello message WITHOUT metadata
echo.
curl -X GET "http://localhost:8080/demo/hello?metadata=false"
echo.
echo.

echo [4/5] Testing POST /demo/echo with valid JSON
echo Expected: 201 - Echo response with metadata (default)
echo.
curl -X POST http://localhost:8080/demo/echo -H "Content-Type: application/json" -d "{\"message\":\"Hello World\"}"
echo.
echo.

echo [5/5] Testing POST /demo/echo without body (should fail)
echo Expected: 400 - Request body is required
echo.
curl -X POST http://localhost:8080/demo/echo -H "Content-Type: application/json"
echo.
echo.

echo ================================================
echo   All tests completed!
echo ================================================
echo.
echo Note: You can also test this endpoint in your browser:
echo   - GET: http://localhost:8080/demo/hello
echo   - GET: http://localhost:8080/demo/hello?metadata=false
echo.
pause 