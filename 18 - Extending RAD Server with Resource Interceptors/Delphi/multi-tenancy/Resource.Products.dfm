object ProductsResource1: TProductsResource1
  Height = 300
  Width = 600
  object FDQProducts: TFDQuery
    Connection = FDConnection
    SQL.Strings = (
      'SELECT id, name, description, price, stock '
      'FROM products '
      '{if !SORT}order by !SORT{fi}')
    Left = 224
    Top = 176
    MacroData = <
      item
        Value = Null
        Name = 'SORT'
      end>
    object FDQProductsID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object FDQProductsNAME: TWideStringField
      FieldName = 'NAME'
      Origin = 'NAME'
      Required = True
      Size = 1020
    end
    object FDQProductsDESCRIPTION: TWideMemoField
      FieldName = 'DESCRIPTION'
      Origin = 'DESCRIPTION'
      BlobType = ftWideMemo
    end
    object FDQProductsPRICE: TFloatField
      FieldName = 'PRICE'
      Origin = 'PRICE'
      Required = True
    end
    object FDQProductsSTOCK: TIntegerField
      FieldName = 'STOCK'
      Origin = 'STOCK'
      Required = True
    end
  end
  object FDConnection: TFDConnection
    Params.Strings = (
      'User_Name=sysdba'
      'Password=masterkey'
      
        'Database=C:\Users\antonio\Documents\GitHub\RADServer-Docs\18 - E' +
        'xtending RAD Server with Resource Interceptors\Delphi\multi-tena' +
        'ncy\Data\TENANT1.IB'
      'Protocol=TCPIP'
      'Server=localhost'
      'Port=3050'
      'CharacterSet=UTF8'
      'DriverID=IB')
    Left = 224
    Top = 112
  end
  object EMSDataSetResource: TEMSDataSetResource
    AllowedActions = [List, Get, Post, Put, Delete]
    DataSet = FDQProducts
    KeyFields = 'ID'
    Options = [roEnableParams, roEnablePaging, roEnableSorting, roEnablePageSizing, roReturnNewEntityKey, roReturnNewEntityValue, roAppendOnPut, roFDDateTimeFormat]
    Left = 352
    Top = 112
  end
  object FDPhysIBDriverLink1: TFDPhysIBDriverLink
    Left = 224
    Top = 56
  end
end
