// This unit defines the most used values for the OpenAPI definitions
// It's not required to use this approach but for readability, simplicity
// and avoid human mistakes it's recomended to abstract the raw values.

unit Common;

interface

uses EMS.ResourceTypes;

type

  TSpecs = class
    type
      ParamIn = TAPIDocParameter.TParameterIn;
      Types = TAPIDoc.TPrimitiveType;
      Formats = TAPIDoc.TPrimitiveFormat;
  end;

  TMethods = record
    const
      List = 'List';
      Get = 'Get';
      Post = 'Post';
      Put = 'Put';
      Delete = 'Delete';
  end;

  // These are just some of the most common HTTP Status codes.
  TStatus = class
    type
      Ok = record
        const
          Code = 200;
          Reason = 'Ok';
      end;
      Created = record
        const
          Code = 201;
          Reason = 'Created';
      end;
      Accepted = record
        const
          Code = 202;
          Reason = 'Accepted';
      end;
      NoContent = record
        const
          Code = 204;
          Reason = 'No Content';
      end;
      BadRequest = record
        const
          Code = 400;
          Reason = 'Bad Request';
      end;
      Forbidden = record
        const
          Code = 403;
          Reason = 'Forbidden';
      end;
      Unauthorized = record
        const
          Code = 401;
          Reason = 'Unauthorized';
      end;
      NotFound = record
        const
          Code = 404;
          Reason = 'Not Found';
      end;
      InternalError = record
        const
          Code = 500;
          Reason = 'Internal Server Error';
      end;
  end;

implementation


end.

