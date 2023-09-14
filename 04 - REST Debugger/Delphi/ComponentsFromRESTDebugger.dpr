program ComponentsFromRESTDebugger;

uses
  System.StartUpCopy,
  FMX.Forms,
  MyForm01 in 'MyForm01.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;

end.
