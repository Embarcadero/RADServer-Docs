unit Resource.Demo;

// EMS Resource Module

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.DateUtils,
  EMS.Services,
  EMS.ResourceAPI,
  EMS.ResourceTypes,
  EMSHosting.Helpers;

type
  [ResourceName('demo')]
  TDemoResource1 = class(TDataModule, IEMSResourceInterceptor)
  private
    FRequestID: string;
    FStartTime: TDateTime;

    // Helper method
    function GenerateRequestID: string;
    function ShouldIncludeMetadata(const ARequest: TEndpointRequest): Boolean;

    // IEMSResourceInterceptor implementation
    procedure BeforeRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse; var AHandled: Boolean);
    procedure AfterRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  published
    [ResourceSuffix('hello')]
    procedure GetHello(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);

    [ResourceSuffix('echo')]
    procedure PostEcho(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

// Helper method
function TDemoResource1.GenerateRequestID: string;
begin
  Result := FormatDateTime('yyyymmdd-hhnnss-', Now) + IntToStr(Random(9999));
end;

// Helper method to check if metadata should be included
function TDemoResource1.ShouldIncludeMetadata(const ARequest: TEndpointRequest): Boolean;
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

// IEMSResourceInterceptor implementation
procedure TDemoResource1.BeforeRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse; var AHandled: Boolean);
begin
  // Initialize request tracking
  FRequestID := GenerateRequestID;
  FStartTime := Now;

  // Log request start
  TLogHelpers.LogMessage(Format('[%s] %s - Started', [FRequestID, ARequest.BasePath]));

  // Simple validation for POST requests
  if ARequest.Method = TEndpointRequest.TMethod.Post then
    try
      // Check if request has a body
      if ARequest.Body.GetString = '' then
      begin
        AResponse.RaiseError(400, 'Request body is required for POST requests', '');
        AHandled := True;
        Exit;
      end;
    except
      on E: Exception do
      begin
        AResponse.RaiseError(400, 'Invalid request format', '');
        AHandled := True;
        Exit;
      end;
    end;
end;


procedure TDemoResource1.AfterRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  Duration: Integer;
  ResponseObj, MetaObj: TJSONObject;
  IncludeMetadata: Boolean;
  StatusCode: Integer;
  ResponseValue: TJSONValue;
begin
  Duration := MillisecondsBetween(Now, FStartTime);

  // Log request completion
  TLogHelpers.LogMessage(Format('[%s] Completed in %dms', [FRequestID, Duration]));

  // Check if metadata should be included
  IncludeMetadata := ShouldIncludeMetadata(ARequest);

  // Only add metadata for successful responses (2xx status codes)
  // Don't try to modify error responses as they may be in an invalid state
  StatusCode := AResponse.StatusCode;
  if IncludeMetadata and (StatusCode >= 200) and (StatusCode < 300) then
  begin
    // Add metadata to response
    try
      AResponse.Body.TryGetValue(ResponseValue);
      // Create new response structure from scratch
      ResponseObj := TJSONObject.Create;
      
      // Preserve the actual response data instead of null
      ResponseObj.AddPair('data', ResponseValue);

      // Add metadata
      MetaObj := TJSONObject.Create;
      MetaObj.AddPair('request_id', FRequestID);
      MetaObj.AddPair('timestamp', DateTimeToStr(Now));
      MetaObj.AddPair('duration_ms', TJSONNumber.Create(Duration));

      ResponseObj.AddPair('meta', MetaObj);
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
end;

// Resource endpoints
procedure TDemoResource1.GetHello(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  ResponseObj: TJSONObject;
begin
  ResponseObj := TJSONObject.Create;
  ResponseObj.AddPair('message', 'Hello from demo interceptor!');

  AResponse.Body.SetValue(ResponseObj, False);
end;


procedure TDemoResource1.PostEcho(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  ResponseObj: TJSONObject;
  RequestBody: TJSONObject;
  ReqMessage: string;
begin
  // Extract message from JSON body (validation already done in BeforeRequest)
  RequestBody := ARequest.Body.GetObject;
  ReqMessage := RequestBody.GetValue<string>('message', '');

  ResponseObj := TJSONObject.Create;
  ResponseObj.AddPair('echo', ReqMessage);

  AResponse.StatusCode := 201; // Created
  AResponse.Body.SetValue(ResponseObj, False);
end;


procedure Register;
begin
  RegisterResource(TypeInfo(TDemoResource1));
end;

initialization
  Register;
end.
