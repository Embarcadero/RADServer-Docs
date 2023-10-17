object TestResource1: TTestResource1
  Height = 267
  Width = 348
  object FDConnection1: TFDConnection
    Params.Strings = (
      'ConnectionDef=EMPLOYEE')
    LoginPrompt = False
    Left = 30
    Top = 16
  end
  object qryCUSTOMER: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from CUSTOMER'
      '&MacroWhere'
      '{if !SORT}order by !SORT{fi}')
    Left = 130
    Top = 16
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
    Left = 130
    Top = 80
  end
  object qrySALES: TFDQuery
    MasterSource = dsCUSTOMER
    MasterFields = 'CUST_NO'
    Connection = FDConnection1
    SQL.Strings = (
      'select * from SALES'
      'where cust_no = :CUST_NO'
      '{if !SORT}order by !SORT{fi}')
    Left = 230
    Top = 16
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
    Left = 230
    Top = 80
  end
  object dsCUSTOMER: TDataSource
    DataSet = qryCUSTOMER
    Left = 128
    Top = 141
  end
end
