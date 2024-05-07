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
  EMS.FileResource;

type

  [ResourceName('test')]
  TDataResource1 = class(TDataModule)
    [ResourceSuffix('./fileResource')]
    [ResourceSuffix('list', './')]
    [ResourceSuffix('get', './{id}')]
    [ResourceSuffix('post', './')]
    EMSFileResource1: TEMSFileResource;
  published
    [ResourceSuffix('./upload')]
    procedure PostUpload(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
      const AResponse: TEndpointResponse);
  end;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}
{$R *.dfm}

uses
  System.IOUtils;

procedure TDataResource1.PostUpload(const AContext: TEndpointContext; const ARequest: TEndpointRequest;
  const AResponse: TEndpointResponse);
begin
  const UPLOAD_PATH = 'c:\uploads'; // change this with the local path you prefer
  TDirectory.CreateDirectory(UPLOAD_PATH);
  AResponse.Body.JSONWriter.WriteStartArray;
  for var i := 0 to ARequest.Body.PartCount - 1 do // check how many files/parts are in the body
  begin
    var lFileName := ARequest.Body.Parts[i].FileName; // accessing the original file name

    // In case of multi platform development it is important to verify if the file name complies with the OS standards
    if not TPath.HasValidFileNameChars(lFileName, false) then
      AResponse.RaiseError(415, 'invalid file name: ', lFileName);

    // The file is created in the local path
    var lFile := TFile.Create(TPath.Combine(UPLOAD_PATH, lFileName));
    try
      // The stream from the body is added to the file
      lFile.CopyFrom(ARequest.Body.Parts[i].GetStream, 0);

      // In this example we return a status code of 201 and as extra info the file name and the file size
      AResponse.StatusCode := 201;
      with AResponse.Body.JSONWriter do
      begin
        WriteStartObject;
        WritePropertyName('fileName');
        WriteValue(lFile.FileName);
        WritePropertyName('size');
        WriteValue(lFile.Size);
        WriteEndObject;
      end;
    finally
      lFile.free;
    end;
  end;
  AResponse.Body.JSONWriter.WriteEndArray;
end;

procedure Register;
begin
  RegisterResource(TypeInfo(TDataResource1));
end;

initialization

Register;

end.
