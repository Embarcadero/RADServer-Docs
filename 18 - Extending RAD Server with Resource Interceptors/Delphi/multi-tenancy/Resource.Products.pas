unit Resource.Products;

// EMS Resource Module
// Multi-Tenancy Demo - Dynamic Database Connection per Tenant

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  Data.DB,
  EMS.Services,
  EMS.ResourceAPI,
  EMS.ResourceTypes,
  EMS.DataSetResource,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.IBDef,
  FireDAC.Phys.IBBase,
  FireDAC.Phys.IB;

const
  // *** IMPORTANT: CHANGE THIS PATH TO YOUR PROJECT LOCATION ***
  // RAD Server packages require absolute paths for the DBs location
  BASE_PATH = 'C:\Users\antonio\Documents\GitHub\RADServer-Docs\18 - Extending RAD Server with Resource Interceptors\Delphi\multi-tenancy\';

type
  [ResourceName('products')]
  TProductsResource1 = class(TDataModule, IEMSResourceInterceptor)
    FDQProducts: TFDQuery;
    FDConnection: TFDConnection;
    [ResourceSuffix('./')]
    EMSDataSetResource: TEMSDataSetResource;
    FDPhysIBDriverLink1: TFDPhysIBDriverLink;
    FDQProductsID: TIntegerField;
    FDQProductsNAME: TWideStringField;
    FDQProductsDESCRIPTION: TWideMemoField;
    FDQProductsPRICE: TFloatField;
    FDQProductsSTOCK: TIntegerField;
  private
    FTenantID: string;
    FConnected: Boolean;

    // Helper methods
    function ExtractTenantID(const ARequest: TEndpointRequest): string;
    function GetDatabasePath(const ATenantID: string): string;
    function ConnectToTenantDatabase(const ATenantID: string): Boolean;
    procedure DisconnectDatabase;
    function GetSortingInfo(const ARequest: TEndpointRequest): string;

    // IEMSResourceInterceptor implementation
    procedure BeforeRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse; var AHandled: Boolean);
    procedure AfterRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

// Extract tenant ID from request header or query parameter
function TProductsResource1.ExtractTenantID(const ARequest: TEndpointRequest): string;
begin
  // Try header first (preferred method)
  if not ARequest.Headers.TryGetValue('X-Tenant-ID', Result) then
    // Fallback to query parameter (browser-friendly)
    Result := ARequest.Params.Values['tenant'];
  
  Result := Result.Trim;
end;

// Get database path for a specific tenant
function TProductsResource1.GetDatabasePath(const ATenantID: string): string;
begin
  Result := '';
  
  // Map tenant IDs to their respective database files
  if ATenantID = 'tenant1' then
    Result := BASE_PATH + 'Data\tenant1.ib'
  else if ATenantID = 'tenant2' then
    Result := BASE_PATH + 'Data\tenant2.ib'
  else if ATenantID = 'tenant3' then
    Result := BASE_PATH + 'Data\tenant3.ib';
  
  // Result will be empty string for unknown tenants
end;

// Connect to the tenant's database
function TProductsResource1.ConnectToTenantDatabase(const ATenantID: string): Boolean;
var
  DBPath: string;
begin
  Result := False;

  try
    // Get database path for this tenant
    DBPath := GetDatabasePath(ATenantID);
    if DBPath = '' then
      Exit; // Unknown tenant
      
    // Check if database file exists
    if not FileExists(DBPath) then
      Exit;

    // Disconnect if already connected
    if FDConnection.Connected then
      FDConnection.Connected := False;

    // Configure connection for InterBase
    FDConnection.DriverName := 'IB';
    FDConnection.Params.Clear;
    FDConnection.Params.DriverID := 'IB';
    FDConnection.Params.UserName := 'SYSDBA';
    FDConnection.Params.Password := 'masterkey';
    FDConnection.Params.Database := DBPath;
    FDConnection.Params.Values['server'] := 'localhost';
    FDConnection.Params.Values['protocol'] := 'TCPIP';
    FDConnection.Params.Values['port'] := '3050';
    FDConnection.Params.Values['CharacterSet'] := 'UTF8';

    // Connect to the database
    FDConnection.Connected := True;
    
    // Configure query component
    FDQProducts.Connection := FDConnection;
    
    FConnected := True;
    Result := True;
  except
    on E: Exception do
    begin
      FConnected := False;
      Result := False;
    end;
  end;
end;

// Disconnect from database
procedure TProductsResource1.DisconnectDatabase;
begin
  try
    if FDQProducts.Active then
      FDQProducts.Close;
    if FDConnection.Connected then
      FDConnection.Connected := False;
    FConnected := False;
  except
    // Ignore errors during cleanup
  end;
end;

// Extract sorting information from request parameters
// TEMSDataSetResource uses format: sf<fieldname>=A|D
// where A=ascending (or empty/-1), D=descending (or 1)
function TProductsResource1.GetSortingInfo(const ARequest: TEndpointRequest): string;
var
  i: Integer;
  ParamName, ParamValue: string;
  SortFields: TStringList;
begin
  Result := '';
  SortFields := TStringList.Create;
  try
    // Look for sorting parameters (format: sf<fieldname>[:A|D])
    for i := 0 to ARequest.Params.Count - 1 do
    begin
      ParamName := ARequest.Params.Pairs[i].Key;
      ParamValue := ARequest.Params.Pairs[i].Value;
      
      // Check if this is a sorting parameter (starts with 'sf')
      if ParamName.StartsWith('sf') then
      begin
        // Extract field name (everything after 'sf')
        ParamName := ParamName.Substring(2);
        
        // Determine sort direction
        if (ParamValue = '') or (ParamValue = '-1') or (ParamValue.ToUpper = 'A') then
          SortFields.Add(ParamName + ':ASC')
        else if (ParamValue = '1') or (ParamValue.ToUpper = 'D') then
          SortFields.Add(ParamName + ':DESC');
      end;
    end;
    
    // Build comma-separated list
    if SortFields.Count > 0 then
      Result := string.Join(', ', SortFields.ToStringArray);
  finally
    SortFields.Free;
  end;
end;

// IEMSResourceInterceptor: BeforeRequest
procedure TProductsResource1.BeforeRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse; var AHandled: Boolean);
var
  ErrorObj: TJSONObject;
  DBPath: string;
begin
  FConnected := False;
  
  // Extract tenant ID from request
  FTenantID := ExtractTenantID(ARequest);
  
  // Validate tenant ID is provided
  if FTenantID = '' then
  begin
    ErrorObj := TJSONObject.Create;
    ErrorObj.AddPair('error', 'Missing tenant identifier');
    ErrorObj.AddPair('message', 'Please provide X-Tenant-ID header or tenant query parameter');
    ErrorObj.AddPair('example_header', 'X-Tenant-ID: tenant1');
    ErrorObj.AddPair('example_param', '?tenant=tenant1');
    
    AResponse.StatusCode := 400;
    AResponse.Body.SetValue(ErrorObj, False);
    AHandled := True;
    Exit;
  end;

  // Check if tenant is valid (has a database configured)
  DBPath := GetDatabasePath(FTenantID);
  if DBPath = '' then
  begin
    ErrorObj := TJSONObject.Create;
    ErrorObj.AddPair('error', 'Unknown tenant');
    ErrorObj.AddPair('message', Format('Tenant "%s" not found', [FTenantID]));

    AResponse.StatusCode := 404;
    AResponse.Body.SetValue(ErrorObj, False);
    AHandled := True;
    Exit;
  end;

  // Check if database file exists
  if not FileExists(DBPath) then
  begin
    ErrorObj := TJSONObject.Create;
    ErrorObj.AddPair('error', 'Database not found');
    ErrorObj.AddPair('message', Format('Database file for tenant "%s" does not exist', [FTenantID]));

    AResponse.StatusCode := 500;
    AResponse.Body.SetValue(ErrorObj, False);
    AHandled := True;
    Exit;
  end;

  // Connect to tenant's database
  if not ConnectToTenantDatabase(FTenantID) then
  begin
    ErrorObj := TJSONObject.Create;
    ErrorObj.AddPair('error', 'Database connection failed');
    ErrorObj.AddPair('message', Format('Could not connect to database for tenant "%s"', [FTenantID]));
    
    AResponse.StatusCode := 500;
    AResponse.Body.SetValue(ErrorObj, False);
    AHandled := True;
    Exit;
  end;

  // Connection successful, proceed to endpoint
  AHandled := False;
end;

// IEMSResourceInterceptor: AfterRequest
procedure TProductsResource1.AfterRequest(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  SortingInfo: string;
begin
  // Cleanup: Disconnect from database
  DisconnectDatabase;
  
  // Add metadata to successful responses via HTTP headers
  if (AResponse.StatusCode >= 200) and (AResponse.StatusCode < 300) then
  begin
    // Always add tenant information as HTTP header
    AResponse.Headers.SetValue('X-Tenant-ID', FTenantID);
    
    // Add pagination headers if pagination parameters were used
    if ARequest.Params.Contains('page') then
    begin
      AResponse.Headers.SetValue('X-Page', ARequest.Params.Values['page']);
      AResponse.Headers.SetValue('X-Page-Size', 
        ARequest.Params.Values['psize']);
    end;
    
    // Add sorting headers if sorting was applied
    SortingInfo := GetSortingInfo(ARequest);
    if SortingInfo <> '' then
      AResponse.Headers.SetValue('X-Sorting', SortingInfo);
  end;
end;

procedure Register;
begin
  RegisterResource(TypeInfo(TProductsResource1));
end;

initialization
  Register;
end.


