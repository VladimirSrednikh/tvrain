program SaveTVRain;

uses
  FastMM4,
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {MainForm},
  untfrmWebTab in 'untfrmWebTab.pas' {frmWebTab: TFrame},
  untIECompat in 'untIECompat.pas',
  untM3U in 'untM3U.pas',
  untRecode in 'untRecode.pas',
  fmuDownloadFile in 'fmuDownloadFile.pas' {frmDownloadFile: TFrame},
  untSettings in 'untSettings.pas',
  untTvRain in 'untTvRain.pas',
  untEchoMskRu in 'untEchoMskRu.pas',
  untWowHead in 'untWowHead.pas',
  untDownloadCommon in 'untDownloadCommon.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
