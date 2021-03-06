object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = #1040#1085#1072#1083#1080#1079' '#1082#1086#1076#1072' '#1085#1072' C/C++. '#1052#1077#1090#1088#1080#1082#1072' '#1052#1072#1082#1082#1077#1081#1073#1072
  ClientHeight = 336
  ClientWidth = 385
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = Menu
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object b_OpenFile: TButton
    Left = 32
    Top = 40
    Width = 129
    Height = 41
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083
    TabOrder = 0
    OnClick = b_OpenFileClick
  end
  object b_EnterText: TButton
    Left = 224
    Top = 40
    Width = 129
    Height = 41
    Caption = #1053#1072#1087#1080#1089#1072#1090#1100
    TabOrder = 1
    OnClick = b_EnterTextClick
  end
  object Answers: TGroupBox
    Left = 8
    Top = 267
    Width = 369
    Height = 62
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object l_NumberOfOperators: TLabel
      Left = 16
      Top = 28
      Width = 154
      Height = 16
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1086#1087#1077#1088#1072#1090#1086#1088#1086#1074' : '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object NumberOfOperators: TLabel
      Left = 200
      Top = 28
      Width = 77
      Height = 16
      Caption = '00000000000'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object b_Analyze: TButton
    Left = 8
    Top = 240
    Width = 369
    Height = 40
    Caption = #1040#1085#1072#1083#1080#1079
    TabOrder = 3
    OnClick = b_AnalyzeClick
  end
  object Code: TMemo
    Left = 7
    Top = 8
    Width = 369
    Height = 226
    Hint = 'Code'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'Code')
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 4
    Visible = False
    WantTabs = True
  end
  object Menu: TMainMenu
    Left = 356
    Top = 65528
    object b_File: TMenuItem
      Caption = 'File'
      object b_Clear: TMenuItem
        Caption = 'Clear'
        OnClick = b_ClearClick
      end
      object b_Exit: TMenuItem
        Caption = 'Exit'
        OnClick = b_ExitClick
      end
    end
    object b_Help: TMenuItem
      Caption = 'Help'
      object b_About: TMenuItem
        Caption = 'About'
        OnClick = b_AboutClick
      end
    end
  end
end
