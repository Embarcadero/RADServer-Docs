unit MyDM;

// EMS Resource Module

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.JSON.Types,
  System.JSON.Writers,
  System.JSON.Builders,
  EMS.Services,
  EMS.ResourceAPI,
  EMS.ResourceTypes;

type

  [ResourceName('test')]
  TTestResource1 = class(TDataModule)
  published
    [ResourceSuffix('./JSON')]
    procedure GetJSON(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
    [ResourceSuffix('./JSONWriter')]
    procedure GetJSONWriter(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
    [ResourceSuffix('./JSONBuilder')]
    procedure GetJSONBuilder(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

procedure TTestResource1.GetJSON(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
begin
  // create some JSON objects
  var JSONRed := TJSONObject.Create;
  JSONRed.AddPair('name', 'red');
  JSONRed.AddPair('hex', '#ff0000');
  JSONRed.AddPair('default', False);
  JSONRed.AddPair('customId', TJSONNull.Create);
  var JSONBlue := TJSONObject.Create;
  JSONBlue.AddPair('name', 'blue');
  JSONBlue.AddPair('hex', '#0000ff');
  JSONBlue.AddPair('default', True);
  JSONBlue.AddPair('customId', 653992);
  // create an array and assign the previous objects to it
  var JSONArray := TJSONArray.Create;
  JSONArray.Add(JSONRed);
  JSONarray.Add(JSONBlue);
  // create an extra object that will contain the array of colors
  var JSONObject := TJSONObject.Create;
  JSONObject.AddPair('colors', JSONArray);
  AResponse.Body.SetValue(JSONObject, True);
end;

procedure TTestResource1.GetJSONWriter(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
begin
  // to avoid typing AResponse.Body.JSONWriter on every line we store it in a variable
  var Writer := AResponse.Body.JSONWriter;
  // start the JSON object
  Writer.WriteStartObject;
  Writer.WritePropertyName('colors');
  // start the JSON Array
  Writer.WriteStartArray;
  Writer.WriteStartObject;
  Writer.WritePropertyName('name');
  Writer.WriteValue('red');
  // add WritePropertyName and WriteValue statements as required
  Writer.WritePropertyName('hex');
  Writer.WriteValue('#ff0000');
  Writer.WritePropertyName('default');
  Writer.WriteValue(False);
  Writer.WritePropertyName('customId');
  Writer.WriteNull;
  Writer.WriteEndObject;
  // write as many additional JSON objects as you need
  Writer.WriteStartObject;
  Writer.WritePropertyName('name');
  Writer.WriteValue('blue');
  Writer.WritePropertyName('hex');
  Writer.WriteValue('#0000ff');
  Writer.WritePropertyName('default');
  Writer.WriteValue(True);
  Writer.WritePropertyName('customId');
  Writer.WriteValue(653992);
  // end the JSON object
  Writer.WriteEndObject;
  // end the JSON array
  Writer.WriteEndArray;
  Writer.WriteEndObject;
end;

procedure TTestResource1.GetJSONBuilder(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
begin
  var Writer := Aresponse.Body.JSONWriter;
  // link the JSONWriter from the response to the builder
  var Builder := TJSONObjectBuilder.Create(Writer);
  try
    Builder
      .BeginObject
        .BeginArray('colors')
          .BeginObject
            .Add('name', 'red')
            .Add('hex', '#ff0000')
            .Add('default', False)
            .AddNull('customId')
          .EndObject
          .BeginObject
            .Add('name', 'blue')
            .Add('hex', '#0000ff')
            .Add('default', True)
            .Add('customId', 653992)
          .EndObject
      .EndArray
    .EndObject;
  finally
    Builder.Free;
  end;
end;

procedure Register;
begin
  RegisterResource(TypeInfo(TTestResource1));
end;

initialization

Register;

end.
