object frmDownloader: TfrmDownloader
  Left = 0
  Top = 0
  Caption = 'frmDownloader'
  ClientHeight = 858
  ClientWidth = 831
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMinimized
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser1: TWebBrowser
    Left = 0
    Top = 0
    Width = 831
    Height = 858
    Align = alClient
    TabOrder = 0
    ExplicitLeft = 40
    ExplicitTop = 8
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C000000E3550000AD5800000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620A000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 392
    Top = 32
  end
end
