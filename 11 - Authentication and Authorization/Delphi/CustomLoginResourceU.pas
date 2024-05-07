unit CustomLoginResourceU;

// EMS Resource Unit

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  EMS.Services,
  EMS.ResourceAPI,
  EMS.ResourceTypes;

type
  {$METHODINFO ON}
  [ResourceName('CustomLogin')]
  TCustomLogonResource = class
  private
    function ValidateExternalCredentials(AUserName, APassword: string): string;
    function CreateExternalUser(AUserName, APassword: string): string;
    function GenerateHashedPassword(AUserName: string): string;
  public
    [EndpointName('CustomSignupUser')]
    // Declare endpoint that matches signature of Users.SignupUser
    [ResourceSuffix('signup')]
    procedure PostSignup(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);

    [EndpointName('CustomLoginUser')]
    // Declare endpoint that matches signature of Users.LoginUser
    [ResourceSuffix('login')]
    procedure PostLogin(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;
  {$METHODINFO OFF}

procedure Register;

implementation

uses System.Hash;

procedure Register;
begin
  RegisterResource(TypeInfo(TCustomLogonResource));
end;

{ TCustomLogonResource }

// Customer external credentials validation
function TCustomLogonResource.ValidateExternalCredentials(AUserName, APassword: string): string;
var
  lUserGUID: TGUID;
  lUserAuthorized: boolean;
  lError: string;
begin
  // Integrate your own logic for verifying the credentials
  lUserAuthorized := true;
  CreateGUID(lUserGUID);
  if not(lUserAuthorized) then
  begin
    lError := 'A more descriptive error';
    EEMSHTTPError.RaiseUnauthorized('unathorized user', lError);
  end;
  Result := lUserGUID.ToString;
end;

// Custom external signup
function TCustomLogonResource.CreateExternalUser(AUserName, APassword: string): string;
var
  lUserGUID: TGUID;
  lError: string;
begin
  CreateGUID(lUserGUID);
  // Integrate your own logic for creating the user. This example will never fail
  if lUserGUID.IsEmpty then
  begin
    lError := 'A more descriptive error';
    EEMSHTTPError.RaiseBadRequest('Bad Request', lError);
  end;
  Result := lUserGUID.ToString;
end;

// This method gererates a hashed version of the user name to use it as password for RAD Server
// Using this approach it will allow the user to change their password on the third party auth service
// and still allow to login automatically in RAD Server. This sytem won't allow change of username though
function TCustomLogonResource.GenerateHashedPassword(AUserName: string): string;
begin
  const SALT = 'my-super-secret-salt';
  Result := System.Hash.THashSHA2.GetHashString(AUserName + SALT);
end;

procedure TCustomLogonResource.PostLogin(const AContext: TEndpointContext;
  const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  lEMSAPI: TEMSInternalAPI;
  lResponse: IEMSResourceResponseContent;
  lValue: TJSONValue;
  lUserName: string;
  lPassword: string;
begin
  // Create in-process EMS API
  lEMSAPI := TEMSInternalAPI.Create(AContext);
  try
    // Extract credentials from request
    if not (ARequest.Body.TryGetValue(LValue) and
      lValue.TryGetValue<string>(TEMSInternalAPI.TJSONNames.UserName, lUserName) and
      lValue.TryGetValue<string>(TEMSInternalAPI.TJSONNames.Password, lPassword)) then
      AResponse.RaiseBadRequest('', 'Missing credentials');

    var lExternalUserGUID := ValidateExternalCredentials(lUserName, lPassword);

    if not LEMSAPI.QueryUserName(lUserName) then
    begin
      // Add user when there is no user for these credentials
      // in-process call to actual Users/Signup endpoint
      var lUserFields := TJSONObject.Create;
      lUserFields.AddPair('ExternalUserGUID', lExternalUserGUID);
      lUserFields.AddPair('comment', 'This user added by RAD Server CustomLoginUser');
      lResponse := lEMSAPI.SignupUser(LUserName, GenerateHashedPassword(lUserName), lUserFields);
    end
    else
      // in-process call to actual Users/Login endpoint
      lResponse := lEMSAPI.LoginUser(lUserName, GenerateHashedPassword(lUserName));
    if lResponse.TryGetValue(lValue) then
      AResponse.Body.SetValue(lValue, False);
  finally
    LEMSAPI.Free;
  end;
end;

// Custom EMS signup
procedure TCustomLogonResource.PostSignup(const AContext: TEndpointContext;
  const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  lEMSAPI: TEMSInternalAPI;
  lResponse: IEMSResourceResponseContent;
  lValue: TJSONObject;
  lUserName: string;
  lPassword: string;
  lUserFields: TJSONObject;
begin
  // Create in-process EMS API
  lEMSAPI := TEMSInternalAPI.Create(AContext);
  try
    // Extract credentials from request
    if not (ARequest.Body.TryGetObject(lValue) and
      lValue.TryGetValue<string>(TEMSInternalAPI.TJSONNames.UserName, lUserName) and
      lValue.TryGetValue<string>(TEMSInternalAPI.TJSONNames.Password, lPassword)) then
      AResponse.RaiseBadRequest('', 'Missing credentials');

    var lExternalUserGUID := CreateExternalUser(lUserName, lPassword);
    lUserFields := lValue.Clone as TJSONObject;
    try
      // Remove meta data
      lUserFields.RemovePair(TEMSInternalAPI.TJSONNames.UserName);
      lUserFields.RemovePair(TEMSInternalAPI.TJSONNames.Password);
      // Add another fields, for example
      lUserFields.AddPair('ExternalUserGUID', lExternalUserGUID);
      lUserFields.AddPair('comment', 'This user added by RAD Server CustomSignupUser');
      // in-process call to actual Users/Signup endpoint
      lResponse := LEMSAPI.SignupUser(LUserName, GenerateHashedPassword(lUserName), lUserFields)
    finally
      lUserFields.Free;
    end;
    if lResponse.TryGetObject(lValue) then
      AResponse.Body.SetValue(lValue, False);
  finally
    lEMSAPI.Free;
  end;
end;


end.


