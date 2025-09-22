unit HighScores.Params;

interface

uses
  EMS.ResourceAPI, EMS.ResourceTypes, System.SysUtils;

type
  TChangeViewParams = Record
  public
    DeviceID : string;
    ChangeViewName : string;
    Constructor Create(const AContext: TEndpointContext; const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
  end;

implementation

{ TChangeViewParams }

constructor TChangeViewParams.Create(const AContext: TEndpointContext;
  const ARequest: TEndpointRequest; const AResponse: TEndpointResponse);
begin
  DeviceID := ARequest.Params.Values['deviceid'];
  ChangeViewName := 'sub_highscore';

  if Self.DeviceID.IsEmpty then
    EEMSHTTPError.RaiseBadRequest('DeviceID Missing');
end;

end.
