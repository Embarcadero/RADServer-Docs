unit Unit1;

// EMS Resource Module

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  EMS.Services, EMS.ResourceAPI, EMS.ResourceTypes;

type
  TEmpsProvider = class(TComponent, IEMSEndpointPublisher)
  private
    class var FArray: TJSONArray;
  private
    function GetItemByID(ARequest: TEndpointRequest): Integer;
    class constructor Create;
    class destructor Destroy;
  public
    procedure Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
    [ResourceSuffix('./{id}')]
    procedure GetItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
    [ResourceSuffix('./{id}')]
    procedure Put(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
    procedure Post(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
    [ResourceSuffix('./{id}')]
    procedure Delete(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
  end;

  [ResourceName('test')]
  TTestResource1 = class(TDataModule)
  public
    Emps: TEmpsProvider;
    constructor Create(AOwner: TComponent);
  published
    procedure Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses
  System.JSON.Builders, System.JSON.Writers, System.JSON.Readers;

{ TEmpsProvider }
class constructor TEmpsProvider.Create;
var
  LWriter: TJsonObjectWriter;
  LBuilder: TJSONArrayBuilder;
begin
  LWriter := TJsonObjectWriter.Create(False);
  LBuilder := TJSONArrayBuilder.Create(LWriter);
  try
    LBuilder
      .BeginArray
        .BeginObject
          .Add('id', '1')
          .Add('first_name', 'John')
          .Add('second_name', 'Smith')
        .EndObject
        .BeginObject
          .Add('id', '2')
          .Add('first_name', 'Poll')
          .Add('second_name', 'Scott')
        .EndObject
        .BeginObject
          .Add('id', '3')
          .Add('first_name', 'Harris')
          .Add('second_name', 'Hill')
        .EndObject
      .EndArray;
    FArray := LWriter.JSON as TJSONArray;
  finally
    LBuilder.Free;
    LWriter.Free;
  end;
end;

class destructor TEmpsProvider.Destroy;
begin
  FArray.Free;
end;

function TEmpsProvider.GetItemByID(ARequest: TEndpointRequest): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to FArray.Count - 1 do
    if (FArray.Items[i] as TJSONObject).GetValue('id').Value = ARequest.Params.Values['id'] then
      Exit(i);
end;

procedure TEmpsProvider.Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
begin
  AResponse.Body.SetValue(FArray, False);
end;

procedure TEmpsProvider.GetItem(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
var
  i: Integer;
begin
  i := GetItemByID(ARequest);
  if i >= 0 then
    AResponse.Body.SetValue(FArray.Items[i], False)
  else
    AResponse.RaiseNotFound('Item is not found');
end;

procedure TEmpsProvider.Put(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
var
  i: Integer;
begin
  i := GetItemByID(ARequest);
  if i >= 0 then
    FArray.Remove(i);
  FArray.Add(ARequest.Body.GetObject.Clone as TJSONObject);
end;

procedure TEmpsProvider.Post(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
var
  i: Integer;
begin
  i := GetItemByID(ARequest);
  if i >= 0 then
    AResponse.RaiseDuplicate('Item already exists')
  else
    FArray.Add(ARequest.Body.GetObject.Clone as TJSONObject);
end;

procedure TEmpsProvider.Delete(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
var
  i: Integer;
begin
  i := GetItemByID(ARequest);
  if i >= 0 then
    FArray.Remove(i)
  else
    AResponse.RaiseNotFound('Item is not found');
end;

constructor TTestResource1.Create(AOwner: TComponent);
begin
  inherited;
  Emps := TEmpsProvider.Create(Self);
end;

{ TTestResource }

procedure TTestResource1.Get(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  // Sample code
  AResponse.Body.SetValue(TJSONString.Create('test'), True);
end;

procedure Register;
begin
  RegisterResource(TypeInfo(TTestResource1));
end;

initialization
  Register;
end.


