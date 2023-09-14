object TestResource1: TTestResource1
  Height = 375
  Width = 750
  PixelsPerInch = 120
  object FDConnection1: TFDConnection
    Params.Strings = (
      'ConnectionDef=EMPLOYEE')
    LoginPrompt = False
    Left = 38
    Top = 20
  end
  object qryCUSTOMER: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from CUSTOMER'
      '&MacroWhere'
      '{if !SORT}order by !SORT{fi}')
    Left = 163
    Top = 20
    MacroData = <
      item
        Value = Null
        Name = 'MACROWHERE'
        DataType = mdIdentifier
      end
      item
        Value = Null
        Name = 'SORT'
      end>
  end
  object dsrCUSTOMER: TEMSDataSetResource
    AllowedActions = [List, Get, Post, Put, Delete]
    DataSet = qryCUSTOMER
    KeyFields = 'CUST_NO'
    PageSize = 5
    Left = 163
    Top = 100
  end
  object qrySALES: TFDQuery
    MasterSource = dsCUSTOMER
    MasterFields = 'CUST_NO'
    Connection = FDConnection1
    SQL.Strings = (
      'select * from SALES'
      'where cust_no = :CUST_NO'
      '{if !SORT}order by !SORT{fi}')
    Left = 288
    Top = 20
    ParamData = <
      item
        Name = 'CUST_NO'
        DataType = ftInteger
        ParamType = ptInput
        Value = Null
      end>
    MacroData = <
      item
        Value = Null
        Name = 'SORT'
      end>
  end
  object dsrSALES: TEMSDataSetResource
    AllowedActions = [List, Get, Post, Put, Delete]
    DataSet = qrySALES
    KeyFields = 'PO_NUMBER'
    Left = 288
    Top = 100
  end
  object dsCUSTOMER: TDataSource
    DataSet = qryCUSTOMER
    Left = 160
    Top = 176
  end
  object FDManager1: TFDManager
    WaitCursor = gcrNone
    FormatOptions.AssignedValues = [fvMapRules]
    FormatOptions.OwnMapRules = True
    FormatOptions.MapRules = <>
    Active = True
    Left = 576
    Top = 368
  end
end
