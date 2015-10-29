unit fmuDownloadFile;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.ComCtrls,
  untM3U;

type
  TFrmDownloadFile = class(TFrame)
    imgPreview: TImage;
    lblFileName: TLabel;
    btnStatus: TSpeedButton;
    pbFile: TProgressBar;
  private
    { Private declarations }
  public
    { Public declarations }
    EagleId: Integer;
    constructor CreateFrame(APlayList: TM3UPlayList; AOwner: TComponent);
  end;

implementation

{$R *.dfm}

{ TFrmDownloadFile }

constructor TFrmDownloadFile.CreateFrame(APlayList: TM3UPlayList; AOwner: TComponent);
begin
  inherited Create(AOwner);
  Name := '';
  EagleId := APlayList.FEagleId;
  if AOwner is TWinControl then
    Parent := AOwner as TWinControl;
  lblFileName.Caption := APlayList.Title;
  pbFile.Max := APlayList.TrackCount;
  pbFile.Position := 0;
  pbFile.Visible := True;
  Self.Align := alBottom;
end;

end.
