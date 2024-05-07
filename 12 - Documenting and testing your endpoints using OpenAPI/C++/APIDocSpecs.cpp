//---------------------------------------------------------------------------

#pragma hdrstop

#include <System.hpp>

#include "APIDocSpecs.h"

//---------------------------------------------------------------------------
#pragma package(smart_init)


namespace APISpecs {

	System::String initYamlDefinitions()
	{
		return "# " sLineBreak
		" customer:" sLineBreak
		"  type: object" sLineBreak
		"  properties:" sLineBreak
		"    CUST_NO:" sLineBreak
		"      type: integer" sLineBreak
		"      format: int32" sLineBreak
		"      description: Primary key" sLineBreak
		"      readOnly: true" sLineBreak
		"    CUSTOMER:" sLineBreak
		"      type: string" sLineBreak
		"    CONTACT_FIRST:" sLineBreak
		"      type: string" sLineBreak
		"    CONTACT_LAST:" sLineBreak
		"      type: string" sLineBreak
		"    PHONE_NO:" sLineBreak
		"      type: string" sLineBreak
		"    ADDRESS_LINE1:" sLineBreak
		"      type: string" sLineBreak
		"    ADDRESS_LINE2:" sLineBreak
		"      type: string" sLineBreak
		"    CITY:" sLineBreak
		"      type: string" sLineBreak
		"    STATE_PROVINCE:" sLineBreak
		"      type: string" sLineBreak
		"    COUNTRY:" sLineBreak
		"      type: string" sLineBreak
		"    POSTAL_CODE:" sLineBreak
		"      type: string" sLineBreak
		"    ON_HOLD:" sLineBreak
		"      type: string" sLineBreak
		" sale:" sLineBreak
		"  type: object" sLineBreak
		"  properties:" sLineBreak
		"    PO_NUMBER:" sLineBreak
		"      type: string" sLineBreak
		"      description: Primary key" sLineBreak
		"      readOnly: true" sLineBreak
		"    CUST_NO:" sLineBreak
		"      type: integer" sLineBreak
		"      description: Customer numer" sLineBreak
		"    SALES_REP:" sLineBreak
		"      type: integer" sLineBreak
		"    ORDER_STATUS:" sLineBreak
		"      type: string" sLineBreak
		"    ORDER_DATE:" sLineBreak
		"      type: string" sLineBreak
		"      format: date" sLineBreak
		"    SHIP_DATE:" sLineBreak
		"      type: string" sLineBreak
		"      format: date-time" sLineBreak
		"      example: 2024-07-21T17:32:28Z" sLineBreak
		"    DATE_NEEDED:" sLineBreak
		"      type: string" sLineBreak
		"      format: date-time" sLineBreak
		"    PAID:" sLineBreak
		"      type: string" sLineBreak
		"      example: Y or N" sLineBreak
		"    QTY_ORDERED:" sLineBreak
		"      type: integer" sLineBreak
		"    TOTAL_VALUE:" sLineBreak
		"      type: number" sLineBreak
		"      format: currency" sLineBreak
		"    DISCOUNT:" sLineBreak
		"      type: number" sLineBreak
		"    ITEM_TYPE:" sLineBreak
		"      type: string" sLineBreak
		"    AGED:" sLineBreak
		"      type: number" sLineBreak
		"#" sLineBreak
		" ItemPostedResponseObject:" sLineBreak
		"   type: object" sLineBreak
		"   properties:" sLineBreak
		"     PostedData:" sLineBreak
		"       type: array" sLineBreak
		"       items:" sLineBreak
		"         type: string" sLineBreak
		"#" sLineBreak
		" ItemPutResponseObject:" sLineBreak
		"   type: object" sLineBreak
		"   properties:" sLineBreak
		"     PathItem:" sLineBreak
		"       type: string" sLineBreak
		"     PostedData:" sLineBreak
		"       type: array" sLineBreak
		"       items:" sLineBreak
		"         type: string" sLineBreak
		"";
	}


	System::String initJSONDefinitions()
	{
		return "{" sLineBreak
		"  \"customer\": {" sLineBreak
		"    \"type\": \"object\"," sLineBreak
		"    \"properties\": {" sLineBreak
		"      \"CUST_NO\": {" sLineBreak
		"        \"type\": \"integer\"," sLineBreak
		"        \"format\": \"int32\"," sLineBreak
		"        \"description\": \"Primary key\"," sLineBreak
		"        \"readOnly\": true" sLineBreak
		"      }," sLineBreak
		"      \"CUSTOMER\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"CONTACT_FIRST\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"CONTACT_LAST\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"PHONE_NO\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"ADDRESS_LINE1\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"ADDRESS_LINE2\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"CITY\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"STATE_PROVINCE\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"COUNTRY\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"POSTAL_CODE\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"ON_HOLD\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }" sLineBreak
		"    }" sLineBreak
		"  }," sLineBreak
		"  \"sale\": {" sLineBreak
		"    \"type\": \"object\"," sLineBreak
		"    \"properties\": {" sLineBreak
		"      \"PO_NUMBER\": {" sLineBreak
		"        \"type\": \"string\"," sLineBreak
		"        \"description\": \"Primary key\"," sLineBreak
		"        \"readOnly\": true" sLineBreak
		"      }," sLineBreak
		"      \"CUST_NO\": {" sLineBreak
		"        \"type\": \"integer\"," sLineBreak
		"        \"description\": \"Customer number\"" sLineBreak
		"      }," sLineBreak
		"      \"SALES_REP\": {" sLineBreak
		"        \"type\": \"integer\"" sLineBreak
		"      }," sLineBreak
		"      \"ORDER_STATUS\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"ORDER_DATE\": {" sLineBreak
		"        \"type\": \"string\"," sLineBreak
		"        \"format\": \"date\"" sLineBreak
		"      }," sLineBreak
		"      \"SHIP_DATE\": {" sLineBreak
		"        \"type\": \"string\"," sLineBreak
		"        \"format\": \"date-time\"," sLineBreak
		"        \"example\": \"2024-07-21T17:32:28Z\"" sLineBreak
		"      }," sLineBreak
		"      \"DATE_NEEDED\": {" sLineBreak
		"        \"type\": \"string\"," sLineBreak
		"        \"format\": \"date-time\"" sLineBreak
		"      }," sLineBreak
		"      \"PAID\": {" sLineBreak
		"        \"type\": \"string\"," sLineBreak
		"        \"example\": \"Y or N\"" sLineBreak
		"      }," sLineBreak
		"      \"QTY_ORDERED\": {" sLineBreak
		"        \"type\": \"integer\"" sLineBreak
		"      }," sLineBreak
		"      \"TOTAL_VALUE\": {" sLineBreak
		"        \"type\": \"number\"," sLineBreak
		"        \"format\": \"currency\"" sLineBreak
		"      }," sLineBreak
		"      \"DISCOUNT\": {" sLineBreak
		"        \"type\": \"number\"" sLineBreak
		"      }," sLineBreak
		"      \"ITEM_TYPE\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"AGED\": {" sLineBreak
		"        \"type\": \"number\"" sLineBreak
		"      }" sLineBreak
		"    }" sLineBreak
		"  }," sLineBreak
		"  \"ItemPostedResponseObject\": {" sLineBreak
		"    \"type\": \"object\"," sLineBreak
		"    \"properties\": {" sLineBreak
		"      \"PostedData\": {" sLineBreak
		"        \"type\": \"array\"," sLineBreak
		"        \"items\": {" sLineBreak
		"          \"type\": \"string\"" sLineBreak
		"        }" sLineBreak
		"      }" sLineBreak
		"    }" sLineBreak
		"  }," sLineBreak
		"  \"ItemPutResponseObject\": {" sLineBreak
		"    \"type\": \"object\"," sLineBreak
		"    \"properties\": {" sLineBreak
		"      \"PathItem\": {" sLineBreak
		"        \"type\": \"string\"" sLineBreak
		"      }," sLineBreak
		"      \"PostedData\": {" sLineBreak
		"        \"type\": \"array\"," sLineBreak
		"        \"items\": {" sLineBreak
		"          \"type\": \"string\"" sLineBreak
		"        }" sLineBreak
		"      }" sLineBreak
		"    }" sLineBreak
		"  }" sLineBreak
		"}" sLineBreak
		"";
	}
}
