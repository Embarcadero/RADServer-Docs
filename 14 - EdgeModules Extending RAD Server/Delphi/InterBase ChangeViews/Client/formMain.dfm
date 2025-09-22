object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 520
  ClientWidth = 734
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    734
    520)
  TextHeight = 15
  object Label1: TLabel
    Left = 0
    Top = 73
    Width = 734
    Height = 15
    Align = alTop
    Caption = 'Stats'
    ExplicitWidth = 25
  end
  object Label2: TLabel
    Left = 12
    Top = 314
    Width = 146
    Height = 15
    Caption = 'Sessions Lifespan (Seconds)'
  end
  object MemoStatus: TMemo
    Left = 0
    Top = 88
    Width = 734
    Height = 188
    Align = alTop
    Lines.Strings = (
      'MemoStatus')
    TabOrder = 0
    ExplicitWidth = 637
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 734
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 637
    object Button1: TButton
      Left = 12
      Top = 17
      Width = 117
      Height = 40
      Margins.Left = 2
      Margins.Top = 2
      Margins.Right = 2
      Margins.Bottom = 2
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object seLifeSpanSeconds: TSpinEdit
    Left = 208
    Top = 313
    Width = 93
    Height = 24
    MaxValue = 3600
    MinValue = 5
    TabOrder = 2
    Value = 60
  end
  object btnSweep: TButton
    Left = 109
    Top = 344
    Width = 289
    Height = 48
    Anchors = [akTop, akRight]
    Caption = 'Sweep'
    TabOrder = 3
    OnClick = btnSweepClick
    ExplicitLeft = 12
  end
  object EMSEdgeService1: TEMSEdgeService
    ModuleName = 'ChangeViewsDemo'
    ModuleVersion = '1'
    Provider = EMSProvider1
    ListenerProtocol = 'http'
    ListenerService.Port = 8888
    ListenerService.Host = 'localhost'
    Left = 136
    Top = 184
  end
  object EMSProvider1: TEMSProvider
    ApiVersion = '2'
    URLHost = 'localhost'
    URLPort = 8080
    Left = 40
    Top = 184
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    ScreenCursor = gcrHourGlass
    Left = 256
    Top = 16
  end
  object TimerStatsUpdate: TTimer
    OnTimer = TimerStatsUpdateTimer
    Left = 40
    Top = 120
  end
  object TimerSweep: TTimer
    OnTimer = TimerSweepTimer
    Left = 136
    Top = 120
  end
end
