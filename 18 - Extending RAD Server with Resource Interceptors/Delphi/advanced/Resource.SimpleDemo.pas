unit Resource.SimpleDemo;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  EMS.Services,
  EMS.ResourceAPI,
  EMS.ResourceTypes,
  EMSHosting.Helpers,
  BaseInterceptor;

type
  [ResourceName('demo')]
  TSimpleDemoResource = class(TBaseInterceptor)
  protected
    procedure DoCustomValidation(const ARequest: TEndpointRequest; var AValid: Boolean; var AErrorMessage: string); override;
    procedure DoCustomLogging(const ARequest: TEndpointRequest; const AResponse: TEndpointResponse); override;
  published
    [ResourceSuffix('hello')]
    procedure GetHello(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
    [ResourceSuffix('echo')]
    procedure PostEcho(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

procedure TSimpleDemoResource.DoCustomValidation(const ARequest: TEndpointRequest; var AValid: Boolean; var AErrorMessage: string);
var
  RequestBody: TJSONObject;
begin
  // Call parent validation first
  inherited DoCustomValidation(ARequest, AValid, AErrorMessage);

  if not AValid then
    Exit;

  // Add simple custom validation for POST requests
  if ARequest.Method = TEndpointRequest.TMethod.Post then
    try
      RequestBody := ARequest.Body.GetObject;
      if not Assigned(RequestBody) then
      begin
        AValid := False;
        AErrorMessage := 'Request body is required for POST requests';
        Exit;
      end;

      // Simple validation - require a "message" field
      if RequestBody.GetValue<string>('message', '') = '' then
      begin
        AValid := False;
        AErrorMessage := 'Message field is required';
        Exit;
      end;

    except
      on E: Exception do
      begin
        AValid := False;
        AErrorMessage := 'Invalid JSON format: ' + E.Message;
      end;
    end;
end;


procedure TSimpleDemoResource.DoCustomLogging(const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  // Add custom logging for successful requests
  // Read status code directly from response
  if AResponse.StatusCode = 200 then
    TLogHelpers.LogMessage(Format('[DEMO] Simple demo request completed by user: %s', [CurrentUserID]));

  // Call parent logging
  inherited DoCustomLogging(ARequest, AResponse);
end;


procedure TSimpleDemoResource.GetHello(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  ResponseObj: TJSONObject;
begin
  ResponseObj := TJSONObject.Create;
  ResponseObj.AddPair('message', 'Hello from simple demo!');
  ResponseObj.AddPair('user', CurrentUserID);
  ResponseObj.AddPair('timestamp', DateTimeToStr(Now));
  
  // Set status code directly
  AResponse.StatusCode := 200;
  AResponse.Body.SetValue(ResponseObj, True);
end;


procedure TSimpleDemoResource.PostEcho(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
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
  ResponseObj.AddPair('user', CurrentUserID);
  ResponseObj.AddPair('timestamp', DateTimeToStr(Now));

  // Set status code directly
  AResponse.StatusCode := 201; // Created
  AResponse.Body.SetValue(ResponseObj, True);
end;


procedure Register;
begin
  RegisterResource(TypeInfo(TSimpleDemoResource));
end;

initialization
  Register;
end.
