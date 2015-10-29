object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 600
  ClientWidth = 882
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 605
    Top = 0
    Height = 560
    Align = alRight
    ExplicitLeft = 648
    ExplicitTop = 8
  end
  object pgcPages: TPageControl
    Left = 0
    Top = 0
    Width = 605
    Height = 560
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = 'tsMain'
      object ewbMain: TEmbeddedWB
        Left = 0
        Top = 0
        Width = 597
        Height = 532
        Align = alClient
        TabOrder = 0
        Silent = False
        OnBeforeNavigate2 = ewbMainBeforeNavigate2
        OnNavigateComplete2 = ewbMainNavigateComplete2
        DisableCtrlShortcuts = 'N'
        UserInterfaceOptions = [EnablesFormsAutoComplete, EnableThemes]
        About = ' EmbeddedWB http://bsalsa.com/'
        PrintOptions.HTMLHeader.Strings = (
          '<HTML></HTML>')
        PrintOptions.Orientation = poPortrait
        ExplicitWidth = 577
        ControlData = {
          4C000000021F0000810F00000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E126208000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 560
    Width = 882
    Height = 40
    Align = alBottom
    Caption = 'pnlBottom'
    TabOrder = 2
    object cbxLog: TComboBox
      Left = 1
      Top = 1
      Width = 695
      Height = 21
      Align = alClient
      Style = csDropDownList
      TabOrder = 0
    end
    object pnl2: TPanel
      Left = 696
      Top = 1
      Width = 185
      Height = 38
      Align = alRight
      Caption = 'pnl2'
      TabOrder = 1
      object pbProgressCurrent: TProgressBar
        Left = 1
        Top = 21
        Width = 183
        Height = 20
        Align = alTop
        TabOrder = 1
      end
      object pbCount: TProgressBar
        Left = 1
        Top = 1
        Width = 183
        Height = 20
        Align = alTop
        TabOrder = 0
      end
    end
  end
  object pnlFileList: TPanel
    Left = 608
    Top = 0
    Width = 274
    Height = 560
    Align = alRight
    TabOrder = 1
  end
  object mmMain: TMainMenu
    Left = 364
    Top = 36
    object gototvrain1: TMenuItem
      Caption = 'go to tvrain'
    end
    object mniDownload: TMenuItem
      Caption = 'Download and Close'
      OnClick = mniDownloadClick
    end
    object mniLog: TMenuItem
      Caption = 'Log'
    end
    object mniWowMp3: TMenuItem
      Caption = 'Get '#1054#1089#1090#1088#1086#1074' '#1075#1088#1086#1084#1072
      OnClick = mniWowMp3Click
    end
    object mniEchoMsk: TMenuItem
      Caption = #1057#1082#1072#1095#1072#1090#1100' '#1089' '#1069#1093#1072
      OnClick = mniEchoMskClick
    end
  end
  object IdHTTP1: TIdHTTP
    AllowCookies = True
    HandleRedirects = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 552
  end
  object tmr1: TTimer
    Interval = 500
    OnTimer = tmr1Timer
    Left = 572
    Top = 4
  end
  object XMLDocument1: TXMLDocument
    Left = 576
    Top = 76
    DOMVendorDesc = 'MSXML'
  end
end
