// This unit defines the most used values for the OpenAPI definitions
// It's not required to use this approach but for readability, simplicity
// and avoid human mistakes it's recomended to abstract the raw values.

//---------------------------------------------------------------------------

#pragma hdrstop

#include "Common.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)


class TSpecs {
public:
	using ParamIn = TAPIDocParameter::TParameterIn;
	using Types = TAPIDoc::TPrimitiveType;
	using Formats = TAPIDoc::TPrimitiveFormat;
};

class TMethods {
public:
	static const char* List;
	static const char* Get;
	static const char* Post;
	static const char* Put;
	static const char* Delete;
};

const char* TMethods::List = "List";
const char* TMethods::Get = "Get";
const char* TMethods::Post = "Post";
const char* TMethods::Put = "Put";
const char* TMethods::Delete = "Delete";


class TStatus {
public:
    struct Ok {
        static const int Code = 200;
        static const char* Reason;
    };

    struct Created {
        static const int Code = 201;
        static const char* Reason;
    };

    struct Accepted {
        static const int Code = 202;
        static const char* Reason;
    };

    struct NoContent {
        static const int Code = 204;
        static const char* Reason;
    };

    struct BadRequest {
        static const int Code = 400;
        static const char* Reason;
    };

    struct Forbidden {
        static const int Code = 403;
        static const char* Reason;
    };

    struct Unauthorized {
        static const int Code = 401;
        static const char* Reason;
    };

    struct NotFound {
        static const int Code = 404;
        static const char* Reason;
    };

    struct InternalError {
        static const int Code = 500;
        static const char* Reason;
    };
};

const char* TStatus::Ok::Reason = "Ok";
const char* TStatus::Created::Reason = "Created";
const char* TStatus::Accepted::Reason = "Accepted";
const char* TStatus::NoContent::Reason = "No Content";
const char* TStatus::BadRequest::Reason = "Bad Request";
const char* TStatus::Forbidden::Reason = "Forbidden";
const char* TStatus::Unauthorized::Reason = "Unauthorized";
const char* TStatus::NotFound::Reason = "Not Found";
const char* TStatus::InternalError::Reason = "Internal Server Error";

UnicodeString generateMethod(const UnicodeString& resource, const char* method) {
	UnicodeString n = UnicodeString(resource) + "." + UnicodeString(method);
	return UnicodeString(resource) + "." + UnicodeString(method);
}
