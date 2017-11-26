object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 496
  ClientWidth = 973
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object spl1: TSplitter
    Left = 693
    Top = 0
    Height = 456
    Align = alRight
    ExplicitLeft = 648
    ExplicitTop = 8
    ExplicitHeight = 560
  end
  object pgcPages: TPageControl
    Left = 0
    Top = 0
    Width = 693
    Height = 456
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = 'tsMain'
      OnShow = tsMainShow
      object ewbMain: TWebBrowser
        Left = 0
        Top = 0
        Width = 685
        Height = 428
        Align = alClient
        TabOrder = 0
        OnNavigateComplete2 = ewbMainNavigateComplete2
        ExplicitHeight = 448
        ControlData = {
          4C000000CC4600003C2C00000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E12620A000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
    object tsWowSound: TTabSheet
      Caption = 'WowSound'
      ImageIndex = 1
      object pnlTop: TPanel
        Left = 0
        Top = 0
        Width = 685
        Height = 37
        Align = alTop
        TabOrder = 0
        DesignSize = (
          685
          37)
        object edtWowURL: TEdit
          Left = 8
          Top = 8
          Width = 265
          Height = 21
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          Text = 'http://www.wowhead.com/zone=210/icecrown'
        end
        object btnGoWow: TBitBtn
          Left = 511
          Top = 6
          Width = 45
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Go!'
          TabOrder = 1
          OnClick = btnGoWowClick
        end
        object btnDownloadWowSound: TButton
          Left = 562
          Top = 6
          Width = 113
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'DownloadWowSound'
          TabOrder = 2
          OnClick = btnDownloadWowSoundClick
        end
        object btnEnumAllZones: TButton
          Left = 400
          Top = 6
          Width = 81
          Height = 25
          Caption = 'EnumAllZones'
          TabOrder = 3
          OnClick = btnEnumAllZonesClick
        end
      end
      object ewbWoW: TWebBrowser
        Left = 0
        Top = 37
        Width = 685
        Height = 391
        Align = alClient
        TabOrder = 1
        OnNavigateComplete2 = ewbMainNavigateComplete2
        ExplicitHeight = 411
        ControlData = {
          4C000000CC460000692800000000000000000000000000000000000000000000
          000000004C000000000000000000000001000000E0D057007335CF11AE690800
          2B2E12620A000000000000004C0000000114020000000000C000000000000046
          8000000000000000000000000000000000000000000000000000000000000000
          00000000000000000100000000000000000000000000000000000000}
      end
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 456
    Width = 973
    Height = 40
    Align = alBottom
    Caption = 'pnlBottom'
    TabOrder = 1
    object cbxLog: TComboBox
      Left = 1
      Top = 1
      Width = 786
      Height = 21
      Align = alClient
      Style = csDropDownList
      TabOrder = 0
    end
    object pnl2: TPanel
      Left = 787
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
        Step = 1
        TabOrder = 0
      end
    end
  end
  object pnlFileList: TScrollBox
    Left = 696
    Top = 0
    Width = 277
    Height = 456
    Align = alRight
    BevelOuter = bvSpace
    TabOrder = 2
    Visible = False
  end
  object mmMain: TMainMenu
    Left = 364
    Top = 36
    object gototvrain1: TMenuItem
      Caption = 'go to tvrain'
    end
    object mniDownloadAllTVRain: TMenuItem
      Caption = #1057#1082#1072#1095#1072#1090#1100' '#1074#1089#1077' '#1088#1086#1083#1080#1082#1080
      OnClick = mniDownloadAllTVRainClick
    end
    object mniDownload: TMenuItem
      Caption = 'Download and GoBack'
      OnClick = mniDownloadClick
    end
    object mniLog: TMenuItem
      Caption = 'Log'
    end
    object mniEchoMsk: TMenuItem
      Caption = #1057#1082#1072#1095#1072#1090#1100' '#1089' '#1069#1093#1072
      object mniEchoDownloadLast: TMenuItem
        Caption = #1057#1082#1072#1095#1072#1090#1100' '#1087#1086#1089#1083#1077#1076#1085#1077#1077
        OnClick = mniEchoDownloadLastClick
      end
      object mniEchoMakePlaylist: TMenuItem
        Caption = #1054#1073#1085#1086#1074#1080#1090#1100' playlist'
        OnClick = mniEchoMakePlaylistClick
      end
    end
  end
  object IdHTTP1: TIdHTTP
    IOHandler = IdSSLIOHandlerSocketOpenSSL1
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
    Left = 568
    Top = 65528
  end
  object tmr1: TTimer
    Interval = 500
    OnTimer = tmr1Timer
    Left = 636
    Top = 92
  end
  object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 664
    Top = 65512
  end
end
