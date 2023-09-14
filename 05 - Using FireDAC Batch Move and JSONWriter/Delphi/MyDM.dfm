object FireDACResource1: TFireDACResource1
  Height = 315
  Width = 919
  PixelsPerInch = 120
  object EmployeeConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=EMPLOYEE')
    Left = 120
    Top = 80
  end
  object EmployeeQuery: TFDQuery
    Connection = EmployeeConnection
    SQL.Strings = (
      'SELECT *'
      'FROM employee')
    Left = 120
    Top = 180
  end
  object FDBatchMoveJSONWriter1: TFDBatchMoveJSONWriter
    DataDef.Fields = <>
    Left = 750
    Top = 130
  end
  object FDBatchMove1: TFDBatchMove
    Reader = FDBatchMoveDataSetReader1
    Writer = FDBatchMoveJSONWriter1
    Mappings = <>
    LogFileName = 'Data.log'
    Left = 550
    Top = 80
  end
  object FDBatchMoveDataSetReader1: TFDBatchMoveDataSetReader
    DataSet = EmployeeQuery
    Left = 550
    Top = 180
  end
  object FDStanStorageJSONLink1: TFDStanStorageJSONLink
    Left = 310
    Top = 140
  end
end
