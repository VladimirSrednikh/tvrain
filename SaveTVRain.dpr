program SaveTVRain;

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {MainForm},
  untfrmWebTab in 'untfrmWebTab.pas' {frmWebTab: TFrame},
  untIECompat in 'untIECompat.pas',
  untM3U in 'untM3U.pas',
  untRecode in 'untRecode.pas',
  fmuDownloadFile in 'fmuDownloadFile.pas' {frmDownloadFile: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
