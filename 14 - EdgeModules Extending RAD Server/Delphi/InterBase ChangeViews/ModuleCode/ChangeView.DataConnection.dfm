object ChangeViewConnection: TChangeViewConnection
  Height = 960
  Width = 1280
  object FDConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=sub')
    TxOptions.Isolation = xiSnapshot
    TxOptions.AutoStop = False
    TxOptions.DisconnectAction = xdRollback
    Connected = True
    LoginPrompt = False
    Transaction = FDTransaction1
    Left = 54
    Top = 28
  end
  object qryData: TFDQuery
    Connection = FDConnection
    Transaction = FDTransaction1
    SQL.Strings = (
      'select * from HIGHSCORES'
      '{if !SORT}order by !SORT{fi}')
    Left = 358
    Top = 84
    MacroData = <
      item
        Value = Null
        Name = 'SORT'
      end>
  end
  object qryActivateChangeView: TFDQuery
    Connection = FDConnection
    Transaction = FDTransaction1
    SecurityOptions.AllowedCommandKinds = [skExecute, skStartTransaction, skCommit, skRollback, skSet]
    SecurityOptions.AllowMultiCommands = False
    SQL.Strings = (
      'set subscription !SubscriptionName at !DeviceID active;')
    Left = 242
    Top = 84
    MacroData = <
      item
        Value = 'sub_highscore'
        Name = 'SUBSCRIPTIONNAME'
      end
      item
        Value = 'MyDeviceID'
        Name = 'DEVICEID'
        DataType = mdString
      end>
  end
  object FDTransaction1: TFDTransaction
    Options.Isolation = xiSnapshot
    Options.AutoStop = False
    Options.DisconnectAction = xdRollback
    Connection = FDConnection
    Left = 96
    Top = 96
  end
end
