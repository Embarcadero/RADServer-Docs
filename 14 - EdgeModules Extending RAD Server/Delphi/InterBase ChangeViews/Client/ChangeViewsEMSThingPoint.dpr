program ChangeViewsEMSThingPoint;

uses
  Vcl.Forms,
  formMain in 'formMain.pas' {Form1},
  HighScores.Params in '..\ModuleCode\HighScores.Params.pas',
  HighScores.API in '..\ModuleCode\HighScores.API.pas' {dataHighscoresResource: TDataModule},
  ChangeView.DataConnection in '..\ModuleCode\ChangeView.DataConnection.pas' {ChangeViewConnection: TDataModule},
  ChangeView.Cache in '..\ModuleCode\ChangeView.Cache.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
