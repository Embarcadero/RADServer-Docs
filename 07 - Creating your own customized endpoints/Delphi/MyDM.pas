unit MyDM;

// EMS Resource Module

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  EMS.Services,
  EMS.ResourceAPI,
  EMS.ResourceTypes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.IB,
  FireDAC.Phys.IBDef,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  EMS.DataSetResource,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.VCLUI.Wait;

type

  [ResourceName('test')]
  TTestResource1 = class(TDataModule)
    FDConnection1: TFDConnection;
    qryCUSTOMER: TFDQuery;
    [ResourceSuffix('customers')]
    dsrCUSTOMER: TEMSDataSetResource;
    qrySALES: TFDQuery;
    [ResourceSuffix('customers/{CUST_NO}/sales')]
    [ResourceSuffix('List', './')]
    [ResourceSuffix('Get', './{PO_NUMBER}')]
    [ResourceSuffix('Post', './')]
    [ResourceSuffix('Put', './{PO_NUMBER}')]
    [ResourceSuffix('Delete', './{PO_NUMBER}')]
    dsrSALES: TEMSDataSetResource;
    dsCUSTOMER: TDataSource;
  private
    // If the query has a masterfield defined, it retuns a StringList of all the fields but the masterfield one
    function ExcludeMasterFieldFromFields(ADataset: TFDQuery): TStringList;
    // Serializes a Master/Detail relationship into a JSON Object with the detail query nested as a JSON array in the same object
    function SerializeMasterDetail(AMasterDataset: TFDQuery; ADetailDataset: TFDQuery; APropertyName: string; AFields: TStringList = nil): TJSONObject;
  published
    [ResourceSuffix('./customers-details/')]
    // Returns an array with all the customers and a nested array with all the customer's sales
    procedure GetCustomersDetails(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
    [ResourceSuffix('./customers-details/{CUST_NO}')]
    // Returns a JSON object with the specified customer number and a nested array with all the customer's sales
    procedure GetCustomerDetails(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
    [ResourceSuffix('./custom/{ID}')]
    // Custom mock POST method
    procedure PostCustomEndPoint(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
  end;

implementation

uses
  Data.DBJson;

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

{ TTestResource1 }

procedure TTestResource1.GetCustomersDetails(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
begin
  qryCUSTOMER.Open;
  qryCUSTOMER.First;
  qrySALES.Open;

  var lFields := ExcludeMasterFieldFromFields(qrySALES);

  // this array will store all the objects returned from the ConverToMasterDetail loop
  var lJSONArray := TJSONArray.Create;
  try
    while not(qryCUSTOMER.Eof) do
    begin
      lJSONArray.Add(SerializeMasterDetail(qryCUSTOMER, qrySALES, 'SALES', lFields));
      qryCUSTOMER.Next;
    end;
    AResponse.Body.SetValue(lJSONArray, true);
  finally
    lFields.Free;
    qrySALES.Close;
    qryCUSTOMER.Close;
  end;
end;

procedure TTestResource1.GetCustomerDetails(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
begin
  var lCustomerNo := ARequest.Params.Values['CUST_NO'].ToInteger;
  // We use a parameter instead of concatenating the CustomerNo to avoid SQL injection
  qryCUSTOMER.MacroByName('MacroWhere').AsRaw := 'WHERE CUST_NO = :CUST_NO';
  qryCUSTOMER.ParamByName('CUST_NO').AsInteger := lCustomerNo;
  qryCUSTOMER.Open;
  try
    if qryCUSTOMER.RecordCount = 0 then
      AResponse.RaiseNotFound('Not found', 'Customer ID not found');

    qrySALES.ParamByName('CUST_NO').asInteger := lCustomerNo;
    qrySALES.Open;
    var lFields := ExcludeMasterFieldFromFields(qrySALES);
    try
      AResponse.Body.SetValue(
        SerializeMasterDetail(qryCUSTOMER, qrySALES, 'SALES', lFields)
        , True);
      qrySALES.Close;
    finally
      lFields.Free;
    end;
  finally
    qryCUSTOMER.Close;
    qryCUSTOMER.MacroByName('MacroWhere').Clear;
  end;
end;


procedure TTestResource1.PostCustomEndPoint(const AContext: TEndpointContext;
  const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  lId: integer;
  lName: string;
  lJSON: TJSONObject;
begin
  if not(ARequest.Body.TryGetObject(lJSON) and lJSON.TryGetValue<string>('name', lName)) then
    AResponse.RaiseBadRequest('Bad request', 'Missing data');
  lID := ARequest.Params.Values['ID'].ToInteger;
  // Add your extra business logic
  lName := 'The name is ' + lName;
  AResponse.Body.JSONWriter.WriteStartObject;
  AResponse.Body.JSONWriter.WritePropertyName('id');
  AResponse.Body.JSONWriter.WriteValue(lId);
  AResponse.Body.JSONWriter.WritePropertyName('name');
  AResponse.Body.JSONWriter.WriteValue(lName);
  AResponse.Body.JSONWriter.WriteEndObject;
end;

// given 2 queries with a master/detail relationship, returns 1 JSON object with a nested array with the detail query
function TTestResource1.SerializeMasterDetail(AMasterDataset: TFDQuery; ADetailDataset: TFDQuery; APropertyName: string; AFields: TStringList = nil): TJSONObject;
begin
  var lBridge := TDataSetToJSONBridge.Create;
  try
    // takes the current record of the master query and converts it to a JSON object
    lBridge.Dataset := AMasterDataset;
    lBridge.IncludeNulls := True;
    // specifies that the we only require to process the current record
    lBridge.Area := TJSONDataSetArea.Current;
    // adds the master record as an object in the JSON result
    Result := TJSONObject(lBridge.Produce);

    // in case we passed a list of fields we want to export we assign them to the bridge, otherwise the default behaviour is exporting all fields in the query
    if Assigned(AFields) then
      lBridge.FieldNames.Assign(AFields);
    // the same bridge is being reused, but now the detail dataset is being assigned
    lBridge.Dataset := ADetailDataset;
    // in this case all the records from the query will be processed
    lBridge.Area := TJSONDataSetArea.All;
    // stores the detail array in a temp array to add it afterwards in the main object
    var lJSONarray := TJSONArray(lBridge.Produce);
    // the array is being added to the main object as an array with the propertyname passed in the argument
    Result.AddPair(APropertyName, lJSONarray);
  finally
    lBridge.Free;
  end;
end;

// if a query has a masterfield assigned, it retuns a stringlist with all the fields but that masterfield
function TTestResource1.ExcludeMasterFieldFromFields(ADataset: TFDQuery): TStringList;
begin
  var lMasterField := ADataset.MasterFields;
  Result := TStringList.Create;
  Result.Assign(ADataset.FieldList);
  var i := Result.IndexOf(lMasterField);
  if i > -1 then
    Result.Delete(i);
end;

procedure Register;
begin
  RegisterResource(TypeInfo(TTestResource1));
end;

initialization

Register;

end.
