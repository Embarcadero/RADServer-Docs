unit BaseInterceptor;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.DateUtils,
  System.TypInfo,
  System.Math,
  EMS.Services,
  EMS.ResourceAPI,
  EMS.ResourceTypes,
  EMSHosting.Helpers;

type
  // Simple base interceptor for RAD Server - demonstrates extending a base class
  TBaseInterceptor = class(TInterfacedPersistent, IEMSResourceInterceptor)
  private
    FRequestID: string;
    FStartTime: TDateTime;

  protected
    FCurrentUserID: string;

    // Helper methods
    function GenerateRequestID: string;
    function ExtractAuthToken(const ARequest: TEndpointRequest): string;
    function ValidateAuthToken(const AToken: string): Boolean;
    function GetUserIDFromToken(const AToken: string): string;
    function GetHeaderValue(const ARequest: TEndpointRequest; const AHeaderName: string): string;
    function ShouldIncludeMetadata(const ARequest: TEndpointRequest): Boolean;
    procedure LogRequestStart(const ARequest: TEndpointRequest; const AUserID: string);
    procedure LogRequestComplete(const AStatusCode: Integer; const ADuration: Integer);

    // Virtual methods that can be overridden by descendants
    procedure DoCustomValidation(const ARequest: TEndpointRequest; var AValid: Boolean; var AErrorMessage: string); virtual;
    procedure DoCustomLogging(const ARequest: TEndpointRequest; const AResponse: TEndpointResponse); virtual;
    procedure DoCustomAuthentication(const ARequest: TEndpointRequest; var AAuthenticated: Boolean; var AUserID: string); virtual;

  public
    constructor Create;
    destructor Destroy; override;

    // Access properties for descendant classes
    property CurrentUserID: string read FCurrentUserID;

    // IEMSResourceInterceptor implementation
    procedure BeforeRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse; var AHandled: Boolean);
    procedure AfterRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

// Instance constructor
constructor TBaseInterceptor.Create;
begin
  // No initialization needed for removed fields
end;


destructor TBaseInterceptor.Destroy;
begin
  inherited;
end;

// Helper methods
function TBaseInterceptor.GenerateRequestID: string;
begin
  Result := FormatDateTime('yyyymmdd-hhnnss-', Now) + IntToStr(Random(9999));
end;


function TBaseInterceptor.GetHeaderValue(const ARequest: TEndpointRequest; const AHeaderName: string): string;
begin
  try
    Result := ARequest.Headers.GetValue(AHeaderName);
  except
    on E: Exception do
    begin
      // Header not found or other error
      Result := '';
    end;
  end;
end;


function TBaseInterceptor.ExtractAuthToken(const ARequest: TEndpointRequest): string;
var
  AuthHeader: string;
begin
  // Use custom header to avoid conflicts with RAD Server's built-in auth
  AuthHeader := GetHeaderValue(ARequest, 'X-Custom-Token');
  if AuthHeader <> '' then
    Result := AuthHeader
  else
    Result := '';
end;


function TBaseInterceptor.ValidateAuthToken(const AToken: string): Boolean;
begin
  // Simple validation - in real app, validate JWT or check database
  Result := AToken <> '';
  // For demo purposes, accept any non-empty token
end;


function TBaseInterceptor.GetUserIDFromToken(const AToken: string): string;
begin
  // Simple extraction - in real app, decode JWT and extract user ID
  if AToken.Contains('user:') then
    Result := AToken.Substring(AToken.IndexOf('user:') + 5)
  else if AToken.Contains('admin') then
    Result := 'admin-user'
  else if AToken <> '' then
    Result := 'user-' + AToken.Substring(0, Min(10, Length(AToken))) // Use first 10 chars of token
  else
    Result := 'anonymous';
end;


function TBaseInterceptor.ShouldIncludeMetadata(const ARequest: TEndpointRequest): Boolean;
var
  MetadataParam: string;
begin
  // Default to true (include metadata) for backward compatibility
  Result := True;
  
  try
    MetadataParam := ARequest.Params.Values['metadata'];
    if MetadataParam <> '' then
    begin
      // Parse metadata parameter - accept 'true', '1', 'yes' as true
      MetadataParam := LowerCase(Trim(MetadataParam));
      Result := (MetadataParam = 'true') or (MetadataParam = '1') or (MetadataParam = 'yes');
    end;
  except
    // If there's any error parsing the parameter, default to true
    Result := True;
  end;
end;


procedure TBaseInterceptor.LogRequestStart(const ARequest: TEndpointRequest; const AUserID: string);
begin
  TLogHelpers.LogMessage(Format('[%s] %s %s - User: %s - Started', [
    FRequestID, ARequest.MethodString, ARequest.BasePath, AUserID
    ]));
end;


procedure TBaseInterceptor.LogRequestComplete(const AStatusCode: Integer; const ADuration: Integer);
begin
  TLogHelpers.LogMessage(Format('[%s] Completed in %dms with status %d', [
    FRequestID, ADuration, AStatusCode
    ]));
end;

// IEMSResourceInterceptor implementation
procedure TBaseInterceptor.BeforeRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse; var AHandled: Boolean);
var
  Token: string;
  IsAuthenticated: Boolean;
  UserID: string;
  IsValid: Boolean;
  ErrorMessage: string;
  ErrorResponse: TJSONObject;
begin
  // Initialize request tracking
  FRequestID := GenerateRequestID;
  FStartTime := Now;

  // Authentication
  Token := ExtractAuthToken(ARequest);
  DoCustomAuthentication(ARequest, IsAuthenticated, UserID);

  if not IsAuthenticated then
  begin
    if Token = '' then
    begin
      ErrorResponse := TJSONObject.Create;
      ErrorResponse.AddPair('error', 'Authentication required');
      ErrorResponse.AddPair('message', 'Missing X-Custom-Token header');
    end
    else
    begin
      ErrorResponse := TJSONObject.Create;
      ErrorResponse.AddPair('error', 'Authentication failed');
      ErrorResponse.AddPair('message', 'Invalid custom token');
    end;

    AResponse.StatusCode := 401;
    AResponse.Body.SetValue(ErrorResponse, True);
    AHandled := True;
    Exit;
  end;

  FCurrentUserID := UserID;

  // Custom validation
  DoCustomValidation(ARequest, IsValid, ErrorMessage);
  if not IsValid then
  begin
    ErrorResponse := TJSONObject.Create;
    ErrorResponse.AddPair('error', 'Validation failed');
    ErrorResponse.AddPair('message', ErrorMessage);

    AResponse.StatusCode := 400;
    AResponse.Body.SetValue(ErrorResponse, True);
    AHandled := True;
    Exit;
  end;

  // Log request start
  LogRequestStart(ARequest, FCurrentUserID);
end;


procedure TBaseInterceptor.AfterRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  Duration: Integer;
  StatusCode: Integer;
  IncludeMetadata: Boolean;
  ResponseObj, MetaObj: TJSONObject;
  ResponseValue: TJSONValue;
begin
  Duration := MillisecondsBetween(Now, FStartTime);

  StatusCode := AResponse.StatusCode;

  // Log request completion
  LogRequestComplete(StatusCode, Duration);

  // Check if metadata should be included
  IncludeMetadata := ShouldIncludeMetadata(ARequest);

  // Only add metadata for successful responses (2xx status codes)
  // Don't try to modify error responses as they may be in an invalid state
  if IncludeMetadata and (StatusCode >= 200) and (StatusCode < 300) then
  begin
    // Add metadata to response
    try
      // Create new response structure from scratch
      ResponseObj := TJSONObject.Create;

      if AResponse.Body.TryGetValue(ResponseValue) then
        ResponseObj.AddPair('data', ResponseValue)
      else
        ResponseObj.AddPair('data', TJSONNull.Create);

      // Add metadata
      MetaObj := TJSONObject.Create;
      MetaObj.AddPair('request_id', FRequestID);
      MetaObj.AddPair('timestamp', DateTimeToStr(Now));
      MetaObj.AddPair('duration_ms', TJSONNumber.Create(Duration));
      MetaObj.AddPair('user_id', FCurrentUserID);
      MetaObj.AddPair('method', ARequest.MethodString);
      MetaObj.AddPair('resource', ARequest.Resource);

      ResponseObj.AddPair('meta', MetaObj);

      // Set the new response body
      AResponse.Body.SetValue(ResponseObj, False);
    except
      on E: Exception do
      begin
        // If something goes wrong, just log it but don't break the response
        TLogHelpers.LogMessage(Format('[%s] Error adding metadata: %s', [FRequestID, E.Message]));
      end;
    end;
  end;
  // If metadata is not requested or response is an error, leave the response as-is

  // Allow descendants to add custom logging
  DoCustomLogging(ARequest, AResponse);
end;

// Default implementations - descendants can override these
procedure TBaseInterceptor.DoCustomAuthentication(const ARequest: TEndpointRequest; var AAuthenticated: Boolean; var AUserID: string);
var
  Token: string;
begin
  Token := ExtractAuthToken(ARequest);
  AAuthenticated := ValidateAuthToken(Token);
  if AAuthenticated then
    AUserID := GetUserIDFromToken(Token)
  else
    AUserID := '';
end;


procedure TBaseInterceptor.DoCustomValidation(const ARequest: TEndpointRequest; var AValid: Boolean; var AErrorMessage: string);
var
  ContentType: string;
begin
  // Default validation - just check content type for POST/PUT
  AValid := True;
  if (ARequest.Method = TEndpointRequest.TMethod.Post) or (ARequest.Method = TEndpointRequest.TMethod.Put) then
  begin
    ContentType := GetHeaderValue(ARequest, 'Content-Type');
    if ContentType = '' then
    begin
      AValid := False;
      AErrorMessage := 'Content-Type header is required';
    end
    else if not ContentType.StartsWith('application/json') then
    begin
      AValid := False;
      AErrorMessage := 'Content-Type must be application/json';
    end;
  end;
end;


procedure TBaseInterceptor.DoCustomLogging(const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  // Default implementation does nothing - descendants can override
end;

end.
