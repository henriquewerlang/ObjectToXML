unit ObjectToXML;

interface

uses System.Classes, System.Rtti, System.Generics.Collections, System.SysUtils;

type
  AttributeValueAttribute = class(TCustomAttribute)
  private
    FName: String;
    FValue: String;
  public
    constructor Create(const Name, Value: String);

    property Name: String read FName write FName;
    property Value: String read FValue write FValue;
  end;

  NodeNameAttribute = class(TCustomAttribute)
  private
    FName: String;
  public
    constructor Create(const Name: String);

    property Name: String read FName write FName;
  end;

  EncodingAttribute = class(TCustomAttribute)
  private
    FName: String;
  public
    constructor Create(const Name: String);

    property Name: String read FName write FName;
  end;

  VersionAttribute = class(TCustomAttribute)
  private
    FVersion: String;
  public
    constructor Create(const Version: String);

    property Version: String read FVersion write FVersion;
  end;

  NumberFormatAttribute = class(TCustomAttribute)
  private
    FFormat: String;
  public
    constructor Create(const Format: String);

    property Format: String read FFormat write FFormat;
  end;

  NumberSeparatorAttribute = class(TCustomAttribute)
  private
    FDecimalSeparator: Char;
    FThousandSeparator: Char;
  public
    constructor Create(const DecimalSeparator: Char); overload;
    constructor Create(const ThousandSeparator, DecimalSeparator: Char); overload;

    property DecimalSeparator: Char read FDecimalSeparator write FDecimalSeparator;
    property ThousandSeparator: Char read FThousandSeparator write FThousandSeparator;
  end;

  TXMLReader = class
  private
    FTextReader: TTextReader;
  public
    constructor Create(const TextReader: TTextReader);
  end;

  TXMLWriter = class
  private
    FTextWriter: TTextWriter;
  public
    constructor Create(const TextWriter: TTextWriter);

    function EscapeAttributeValue(AChar: Char): String;
    function EscapeValue(AChar: Char): String;

    procedure WriteAttributeValue(const Value: String);
    procedure WriteEmptyNode(const NodeName: String);
    procedure WriteEndNode(const NodeName: String);
    procedure WriteEscapedValue(const Value: String; const EscapeFunction: TFunc<Char, String>);
    procedure WriteStartNode(const NodeName: String);
    procedure WriteValue(const Value: Extended); overload;
    procedure WriteValue(const Value: Int64); overload;
    procedure WriteValue(const Value: String); overload;
    procedure WriteValue(const Value: UInt64); overload;
  end;

  TXMLSerializerReader = class
  public
  end;

  TXMLSerializerWriter = class
  private
    FContext: TRttiContext;

    procedure WriteNode(const Writer: TXMLWriter; const &Type: TRttiType; const &Object: TObject);
    procedure WriteProperty(const Writer: TXMLWriter; const &Property: TRttiProperty; const &Object: TObject);
  public
    constructor Create;

    destructor Destroy; override;

    procedure Serialize(const Writer: TXMLWriter; const &Object: TObject);
  end;

  TObjectToXML = class
  public
    function Deserialize<T: class>(const XML: String): T; overload;
    function Deserialize<T: class>(const TextReader: TTextReader): T; overload;
    function Serialize(const &Object: TObject): String; overload;

    procedure Serialize(const &Object: TObject; const TextWriter: TTextWriter); overload;
  end;

implementation

{ TObjectToXML }

function TObjectToXML.Deserialize<T>(const XML: String): T;
begin

end;

function TObjectToXML.Deserialize<T>(const TextReader: TTextReader): T;
begin

end;

procedure TObjectToXML.Serialize(const &Object: TObject; const TextWriter: TTextWriter);
begin
  var Serializer := TXMLSerializerWriter.Create;
  var XMLWriter := TXMLWriter.Create(TextWriter);

  try
    Serializer.Serialize(XMLWriter, &Object);
  finally
    Serializer.Free;

    XMLWriter.Free;
  end;
end;

function TObjectToXML.Serialize(const &Object: TObject): String;
begin
  var StringBuilder := TStringBuilder.Create($FFFF);
  var TextWriter := TStringWriter.Create(StringBuilder);

  try
    Serialize(&Object, TextWriter);

    Result := TextWriter.ToString;
  finally
    TextWriter.Free;

    StringBuilder.Free;
  end;
end;

{ NodeNameAttribute }

constructor NodeNameAttribute.Create(const Name: String);
begin
  inherited Create;

  FName := Name;
end;

{ VersionAttribute }

constructor VersionAttribute.Create(const Version: String);
begin
  inherited Create;

  FVersion := Version;
end;

{ EncodingAttribute }

constructor EncodingAttribute.Create(const Name: String);
begin
  inherited Create;

  FName := Name;
end;

{ AttributeValueAttribute }

constructor AttributeValueAttribute.Create(const Name, Value: String);
begin
  inherited Create;

  FName := Name;
  FValue := Value;
end;

{ NumberFormatAttribute }

constructor NumberFormatAttribute.Create(const Format: String);
begin
  inherited Create;

  FFormat := Format;
end;

{ TXMLWriter }

constructor TXMLWriter.Create(const TextWriter: TTextWriter);
begin
  inherited Create;

  FTextWriter := TextWriter;
end;

function TXMLWriter.EscapeAttributeValue(AChar: Char): String;
begin
  if AChar = '"' then
    Result := '&quot;'
  else
    Result := EscapeValue(AChar);
end;

function TXMLWriter.EscapeValue(AChar: Char): String;
begin
  if AChar = '<' then
    Result := '&lt;'
  else if AChar = '>' then
    Result := '&gt;'
  else if AChar = '&' then
    Result := '&amp;'
  else
    Result := AChar;
end;

procedure TXMLWriter.WriteAttributeValue(const Value: String);
begin
  FTextWriter.Write('&lt;&gt;&quot;&amp;''');
  Exit;
end;

procedure TXMLWriter.WriteEmptyNode(const NodeName: String);
begin
  FTextWriter.Write(Format('<%s/>', [NodeName]));
end;

procedure TXMLWriter.WriteEndNode(const NodeName: String);
begin
  FTextWriter.Write(Format('</%s>', [NodeName]));
end;

procedure TXMLWriter.WriteEscapedValue(const Value: String; const EscapeFunction: TFunc<Char, String>);
begin
  for var AChar in Value do
    FTextWriter.Write(EscapeFunction(AChar));
end;

procedure TXMLWriter.WriteStartNode(const NodeName: String);
begin
  FTextWriter.Write(Format('<%s>', [NodeName]));
end;

procedure TXMLWriter.WriteValue(const Value: Int64);
begin
  WriteValue(IntToStr(Value));
end;

procedure TXMLWriter.WriteValue(const Value: Extended);
begin
  WriteValue(FloatToStr(Value));
end;

procedure TXMLWriter.WriteValue(const Value: String);
begin
  WriteEscapedValue(Value, EscapeValue);
end;

procedure TXMLWriter.WriteValue(const Value: UInt64);
begin
  WriteValue(IntToStr(Value));
end;

{ TXMLReader }

constructor TXMLReader.Create(const TextReader: TTextReader);
begin
  inherited Create;

  FTextReader := TextReader;
end;

{ TXMLSerializerWriter }

constructor TXMLSerializerWriter.Create;
begin
  inherited;

  FContext := TRttiContext.Create;
end;

destructor TXMLSerializerWriter.Destroy;
begin
  FContext.Free;

  inherited;
end;

procedure TXMLSerializerWriter.Serialize(const Writer: TXMLWriter; const &Object: TObject);
begin
  WriteNode(Writer, FContext.GetType(&Object.ClassType), &Object);
end;

procedure TXMLSerializerWriter.WriteNode(const Writer: TXMLWriter; const &Type: TRttiType; const &Object: TObject);
begin
  var NodeName: String;
  var NodeNameAttribute := &Type.GetAttribute<NodeNameAttribute>;

  if Assigned(NodeNameAttribute) then
    NodeName := NodeNameAttribute.Name
  else
    NodeName := &Type.Name.SubString(1);

  Writer.WriteStartNode(NodeName);

  for var AProperty in &Type.GetProperties do
    WriteProperty(Writer, AProperty, &Object);

  Writer.WriteEndNode(NodeName);
end;

procedure TXMLSerializerWriter.WriteProperty(const Writer: TXMLWriter; const &Property: TRttiProperty; const &Object: TObject);
var
  PropertyValue: TValue;

  function GetFormatSettings: TFormatSettings;
  begin
    Result := FormatSettings;
  end;

  procedure WriteFloat;
  begin
    var FormatAttribute := &Property.GetAttribute<NumberFormatAttribute>;

    if Assigned(FormatAttribute) then
      Writer.WriteValue(FormatFloat(FormatAttribute.Format, PropertyValue.AsExtended, GetFormatSettings))
    else
      Writer.WriteValue(PropertyValue.AsExtended);
  end;

  procedure WriteValue;
  begin
    case PropertyValue.Kind of
      tkFloat: WriteFloat;
      else Writer.WriteValue(PropertyValue.ToString);
    end;
  end;

begin
  var PropertyName := &Property.Name;
  PropertyValue := &Property.GetValue(&Object);

  if (PropertyValue.Kind in [tkString, tkLString, tkUString, tkWideString]) and PropertyValue.AsString.IsEmpty then
    Writer.WriteEmptyNode(PropertyName)
  else
  begin
    Writer.WriteStartNode(PropertyName);

    WriteValue;

    Writer.WriteEndNode(PropertyName);
  end;
end;

{ NumberSeparatorAttribute }

constructor NumberSeparatorAttribute.Create(const ThousandSeparator, DecimalSeparator: Char);
begin
  Create(DecimalSeparator);

  FThousandSeparator := ThousandSeparator;
end;

constructor NumberSeparatorAttribute.Create(const DecimalSeparator: Char);
begin
  inherited Create;

  FDecimalSeparator := DecimalSeparator;
end;

end.

