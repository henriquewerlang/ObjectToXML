unit ObjectToXML;

interface

uses System.Classes;

type
  AttributeAttribute = class(TCustomAttribute);

  EncodingAttribute = class(TCustomAttribute)
  public
    constructor Create(const );
  end;

  NodeNameAttribute = class(TCustomAttribute)
  public
    constructor Create(const Name: String);
  end;

  VersionAttribute = class(TCustomAttribute)
  public
    constructor Create(const Name: String);
  end;

  TObjectToXML = class
  public
    function Deserialize<T: class>(const XML: String): T;
    function Deserialize<T: class>(const XML: TStream): T;
    function Serialize(const &Object: TObject): String;

    procedure Serialize(const &Object: TObject; const Stream: TStream);
  end;

implementation

{ TObjectToXML }

function TObjectToXML.Deserialize<T>(const XML: String): T;
begin

end;

function TObjectToXML.Deserialize<T>(const XML: TStream): T;
begin

end;

procedure TObjectToXML.Serialize(const &Object: TObject; const Stream: TStream);
begin

end;

function TObjectToXML.Serialize(const &Object: TObject): String;
begin

end;

{ NodeNameAttribute }

constructor NodeNameAttribute.Create(const Name: String);
begin

end;

{ VersionAttribute }

constructor VersionAttribute.Create(const Name: String);
begin

end;

end.
