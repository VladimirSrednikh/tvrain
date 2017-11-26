program TVRain_Downloader;

uses
  Vcl.Forms,
  untIECompat,
  EwbTools,
  untDownloader in 'untDownloader.pas' {frmDownloader},
  untTvRain in 'untTvRain.pas',
  untSettings in 'untSettings.pas',
  untDownloadCommon in 'untDownloadCommon.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmDownloader, frmDownloader);
  Application.ShowMainForm := False;
  PutIECompatible(GetIEVersionMajor, cmrCurrentUser);
  frmDownloader.Show;
  frmDownloader.DownloadFile;
end.
