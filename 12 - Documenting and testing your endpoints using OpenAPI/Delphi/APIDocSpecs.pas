unit APIDocSpecs;

interface

const
  cYamlDefinitions ='''
   customer:
     type: object
     properties:
       CUST_NO:
         type: integer
         format: int32
         description: Primary key
         readOnly: true
       CUSTOMER:
         type: string
       CONTACT_FIRST:
         type: string
       CONTACT_LAST:
         type: string
       PHONE_NO:
         type: string
       ADDRESS_LINE1:
         type: string
       ADDRESS_LINE2:
         type: string
       CITY:
         type: string
       STATE_PROVINCE:
         type: string
       COUNTRY:
         type: string
       POSTAL_CODE:
         type: string
       ON_HOLD:
         type: string
   sale:
     type: object
     properties:
       PO_NUMBER:
         type: string
         description: Primary key
         readOnly: true
       CUST_NO:
         type: integer
         description: Customer number
       SALES_REP:
         type: integer
       ORDER_STATUS:
         type: string
       ORDER_DATE:
         type: string
         format: date
       SHIP_DATE:
         type: string
         format: date-time
         example: 2024-07-21T17:32:28Z
       DATE_NEEDED:
         type: string
         format: date-time
       PAID:
         type: string
         example: Y or N
       QTY_ORDERED:
         type: integer
       TOTAL_VALUE:
         type: number
         format: currency
       DISCOUNT:
         type: number
       ITEM_TYPE:
         type: string
       AGED:
         type: number
  #
   ItemPostedResponseObject:
      type: object
      properties:
        PostedData:
          type: array
          items:
            type: string
  #
   ItemPutResponseObject:
      type: object
      properties:
        PathItem:
          type: string
        PostedData:
          type: array
          items:
            type: string
  ''';

cJSONDefinitions = '''
{
  "customer": {
    "type": "object",
    "properties": {
      "CUST_NO": {
        "type": "integer",
        "format": "int32",
        "description": "Primary key",
        "readOnly": true
      },
      "CUSTOMER": {
        "type": "string"
      },
      "CONTACT_FIRST": {
        "type": "string"
      },
      "CONTACT_LAST": {
        "type": "string"
      },
      "PHONE_NO": {
        "type": "string"
      },
      "ADDRESS_LINE1": {
        "type": "string"
      },
      "ADDRESS_LINE2": {
        "type": "string"
      },
      "CITY": {
        "type": "string"
      },
      "STATE_PROVINCE": {
        "type": "string"
      },
      "COUNTRY": {
        "type": "string"
      },
      "POSTAL_CODE": {
        "type": "string"
      },
      "ON_HOLD": {
        "type": "string"
      }
    }
  },
  "sale": {
    "type": "object",
    "properties": {
      "PO_NUMBER": {
        "type": "string",
        "description": "Primary key",
        "readOnly": true
      },
      "CUST_NO": {
        "type": "integer",
        "description": "Customer number"
      },
      "SALES_REP": {
        "type": "integer"
      },
      "ORDER_STATUS": {
        "type": "string"
      },
      "ORDER_DATE": {
        "type": "string",
        "format": "date"
      },
      "SHIP_DATE": {
        "type": "string",
        "format": "date-time",
        "example": "2024-07-21T17:32:28Z"
      },
      "DATE_NEEDED": {
        "type": "string",
        "format": "date-time"
      },
      "PAID": {
        "type": "string",
        "example": "Y or N"
      },
      "QTY_ORDERED": {
        "type": "integer"
      },
      "TOTAL_VALUE": {
        "type": "number",
        "format": "currency"
      },
      "DISCOUNT": {
        "type": "number"
      },
      "ITEM_TYPE": {
        "type": "string"
      },
      "AGED": {
        "type": "number"
      }
    }
  },
  "ItemPostedResponseObject": {
    "type": "object",
    "properties": {
      "PostedData": {
        "type": "array",
        "items": {
          "type": "string"
        }
      }
    }
  },
  "ItemPutResponseObject": {
    "type": "object",
    "properties": {
      "PathItem": {
        "type": "string"
      },
      "PostedData": {
        "type": "array",
        "items": {
          "type": "string"
        }
      }
    }
  }
}
''';

implementation

end.
