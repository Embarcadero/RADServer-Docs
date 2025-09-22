unit EdgeModuleU;

// EMS Resource Module

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  EMS.Services, EMS.ResourceAPI, EMS.ResourceTypes,
  System.DateUtils;

type
  TFormValues = record
    CheckBox: boolean;
    Edit: string;
    TrackBar: double;
    function ToJSON: TJSONObject;
  end;

  [ResourceName('processor')]
  TProcessorResource1 = class(TDataModule)
  published
    [EndPointRequestSummary('Processor', 'GetCalculate', 'Retrieves item with specified ID', 'application/json', '')]
    [EndPointRequestParameter(TAPIDocParameter.TParameterIn.Path, 'param1', 'Parameter nº 1', true, TAPIDoc.TPrimitiveType.spNumber,
      TAPIDoc.TPrimitiveFormat.None, TAPIDoc.TPrimitiveType.spNumber, '', '')]
    [EndPointRequestParameter(TAPIDocParameter.TParameterIn.Path, 'param2', 'Parameter nº 2', true, TAPIDoc.TPrimitiveType.spNumber,
      TAPIDoc.TPrimitiveFormat.None, TAPIDoc.TPrimitiveType.spNumber, '', '')]
    [EndPointResponseDetails(200, 'Ok', TAPIDoc.TPrimitiveType.spObject, TAPIDoc.TPrimitiveFormat.None, '', '')]
    [ResourceSuffix('calculate')]
    procedure GetCalculate(const AContext: TEndpointContext;
                      const ARequest: TEndpointRequest;
                      const AResponse: TEndpointResponse);
    [ResourceSuffix('formValues')]
    procedure GetFormValues(const AContext: TEndpointContext;
                      const ARequest: TEndpointRequest;
                      const AResponse: TEndpointResponse);
  end;

var FormValues: TFormValues;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TProcessorResource1.GetCalculate(const AContext: TEndpointContext;
  const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
var
  LParam1, LParam2: string;
  LResponse: TJSONObject;
begin
  // Read the input params
    if not(ARequest.Params.TryGetValue('param1', LParam1)) or
       not(ARequest.Params.TryGetValue('param2', LParam2)) then
    AResponse.RaiseBadRequest('Bad request', 'Missing data');
    LResponse := TJSONObject.Create;
    try
      // Calculate the result
      var calculation := LParam1.ToDouble + LParam2.ToDouble;
      // Add your processing logic here
      LResponse.AddPair('status', 'processed');
      LResponse.AddPair('timestamp', DateToISO8601(Now));
      LResponse.AddPair('result', calculation);
      // Send the response
      AResponse.Body.SetValue(LResponse, False);
    finally
      LResponse.Free;
    end;
end;

procedure TProcessorResource1.GetFormValues(const AContext: TEndpointContext;
  const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  AResponse.Body.SetValue(FormValues.ToJSON, True);
end;

{ TFormValues }

function TFormValues.ToJSON: TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('CheckBox', self.CheckBox);
  Result.AddPair('Edit', self.Edit);
  Result.AddPair('TrackBar', self.TrackBar);
end;

procedure Register;
begin
  RegisterResource(TypeInfo(TProcessorResource1));
end;

initialization
  Register;
end.


