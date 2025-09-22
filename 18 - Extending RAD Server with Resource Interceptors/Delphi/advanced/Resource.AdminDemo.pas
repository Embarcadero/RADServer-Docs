unit Resource.AdminDemo;

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
  [ResourceName('admin')]
  TAdminDemoResource = class(TBaseInterceptor)
  protected
    procedure DoCustomAuthentication(const ARequest: TEndpointRequest; var AAuthenticated: Boolean; var AUserID: string); override;
    procedure DoCustomValidation(const ARequest: TEndpointRequest; var AValid: Boolean; var AErrorMessage: string); override;
  published
    [ResourceSuffix('status')]
    procedure GetStatus(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

procedure TAdminDemoResource.DoCustomAuthentication(const ARequest: TEndpointRequest; var AAuthenticated: Boolean; var AUserID: string);
var
  Token: string;
begin
  // Call parent authentication first
  inherited DoCustomAuthentication(ARequest, AAuthenticated, AUserID);

  if not AAuthenticated then
    Exit;

  // Add admin-specific authentication
  Token := ExtractAuthToken(ARequest);
  if not Token.Contains('admin') then
  begin
    AAuthenticated := False;
    AUserID := '';
    TLogHelpers.LogMessage('[ADMIN] Access denied - admin token required');
  end
  else
    TLogHelpers.LogMessage('[ADMIN] Admin access granted');
end;


procedure TAdminDemoResource.DoCustomValidation(const ARequest: TEndpointRequest; var AValid: Boolean; var AErrorMessage: string);
begin
  // Call parent validation
  inherited DoCustomValidation(ARequest, AValid, AErrorMessage);

  if not AValid then
    Exit;

  // Add admin-specific validation if needed
  TLogHelpers.LogMessage('[ADMIN] Admin validation passed');
end;


procedure TAdminDemoResource.GetStatus(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  ResponseObj: TJSONObject;
begin
  ResponseObj := TJSONObject.Create;
  ResponseObj.AddPair('status', 'Admin access confirmed');
  ResponseObj.AddPair('user', CurrentUserID);
  ResponseObj.AddPair('server_time', DateTimeToStr(Now));
  ResponseObj.AddPair('version', '1.0.0');

  AResponse.Body.SetValue(ResponseObj, True);
end;


procedure Register;
begin
  RegisterResource(TypeInfo(TAdminDemoResource));
end;

initialization
  Register;
end.
