unit ObjectToXML.Test;

interface

uses Test.Insight.Framework, System.Classes, ObjectToXML;

type
  [TestFixture]
  TObjectToXMLTest = class
  private
    FSerializer: TObjectToXML;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenSerializeAnObjectMustBuildTheXMLAsExpected;
    [Test]
    procedure WhenSerializeAnObjectWithTextWriterMustBuildTheXMLAsExpected;
  end;

  [TestFixture]
  TXMLWriterTest = class
  private
    FStringWriter: TStringWriter;
    FXMLWriter: TXMLWriter;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenWriteAStartNodeMustWriteTheXMLLikeExpected;
    [Test]
    procedure WhenWriteAnEndNodeMustWriteTheXMLLikeExpected;
    [Test]
    procedure WhenWriteAnEmptyNodeMustWriteTheXMLLikeExpected;
    [Test]
    procedure WhenWriteAValueMustWriteTheTextAsExpected;
    [Test]
    procedure WhenWriteAValueWithSpecialCharMustScapeTheValuesAsExpected;
    [Test]
    procedure WhenWriteAnAttributeValueMustEscapeTheValueAsExpected;
    [Test]
    procedure WhenWriteEscapedValuesMustWriteTheValueAsExpected;
  end;

  [TestFixture]
  TXMLSerializerWriterTest = class
  private
    FStringWriter: TStringWriter;
    FXMLSerializerWriter: TXMLSerializerWriter;
    FXMLWriter: TXMLWriter;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure WhenSerializeAnObjectMustCreateTheDocumentElementWithTheNameOfTheClass;
    [Test]
    procedure WhenSerializeAnObjectWithTheNodeNameAttributeMustCreateTheNodeDocumentoWithTheNameInTheAttribute;
    [Test]
    procedure WhenSerializeAnObjectMustSerializeThePropertiesInTheObject;
  end;

{$M+}
  TSimpleObject = class
  private
    FNode: String;
  published
    property Node: String read FNode write FNode;
  end;

  TEmptyDocument = class
  end;

  [NodeName('MyDocument')]
  TEmptyDocumentWithNodeNameAttribute = class
  end;

  TObjectWithMoreProperties = class
  private
    FNodeFloat: Double;
    FNodeInteger: Integer;
    FNodeString: String;
  published
    property NodeFloat: Double read FNodeFloat write FNodeFloat;
    property NodeInteger: Integer read FNodeInteger write FNodeInteger;
    property NodeString: String read FNodeString write FNodeString;
  end;

  [NumberSeparator('T', 'D')]
  TObjectWithFloatProperty = class
  private
    FValue1: Double;
    FValue2: Double;
    FValue3: Double;
  published
    [NumberFormat('000.000')]
    property Value1: Double read FValue1 write FValue1;
    [NumberFormat('#,##0.000')]
    property Value2: Double read FValue2 write FValue2;
    property Value3: Double read FValue3 write FValue3;
  end;

implementation

{ TObjectToXMLTest }

procedure TObjectToXMLTest.Setup;
begin
  FSerializer := TObjectToXML.Create;
end;

procedure TObjectToXMLTest.TearDown;
begin
  FSerializer.Free;
end;

procedure TObjectToXMLTest.WhenSerializeAnObjectMustBuildTheXMLAsExpected;
begin
  var Obj := TSimpleObject.Create;
  Obj.Node := 'abc';
  var XML := FSerializer.Serialize(Obj);

  Assert.AreEqual('<SimpleObject><Node>abc</Node></SimpleObject>', XML);

  Obj.Free;
end;

procedure TObjectToXMLTest.WhenSerializeAnObjectWithTextWriterMustBuildTheXMLAsExpected;
begin
  var Obj := TSimpleObject.Create;
  Obj.Node := 'abc';
  var TextWriter := TStringWriter.Create;

  FSerializer.Serialize(Obj, TextWriter);

  Assert.AreEqual('<SimpleObject><Node>abc</Node></SimpleObject>', TextWriter.ToString);

  Obj.Free;

  TextWriter.Free;
end;

{ TXMLWriterTest }

procedure TXMLWriterTest.Setup;
begin
  FStringWriter := TStringWriter.Create;
  FXMLWriter := TXMLWriter.Create(FStringWriter);
end;

procedure TXMLWriterTest.TearDown;
begin
  FXMLWriter.Free;

  FStringWriter.Free;
end;

procedure TXMLWriterTest.WhenWriteAnAttributeValueMustEscapeTheValueAsExpected;
begin
  FXMLWriter.WriteAttributeValue('<>"&''');

  Assert.AreEqual('&lt;&gt;&quot;&amp;''', FStringWriter.ToString);
end;

procedure TXMLWriterTest.WhenWriteAnEmptyNodeMustWriteTheXMLLikeExpected;
begin
  FXMLWriter.WriteEmptyNode('MyNode');

  Assert.AreEqual('<MyNode/>', FStringWriter.ToString);
end;

procedure TXMLWriterTest.WhenWriteAnEndNodeMustWriteTheXMLLikeExpected;
begin
  FXMLWriter.WriteEndNode('MyNode');

  Assert.AreEqual('</MyNode>', FStringWriter.ToString);
end;

procedure TXMLWriterTest.WhenWriteAStartNodeMustWriteTheXMLLikeExpected;
begin
  FXMLWriter.WriteStartNode('MyNode');

  Assert.AreEqual('<MyNode>', FStringWriter.ToString);
end;

procedure TXMLWriterTest.WhenWriteAValueMustWriteTheTextAsExpected;
begin
  FXMLWriter.WriteValue('Value');

  Assert.AreEqual('Value', FStringWriter.ToString);
end;

procedure TXMLWriterTest.WhenWriteAValueWithSpecialCharMustScapeTheValuesAsExpected;
begin
  FXMLWriter.WriteValue('<>&"''');

  Assert.AreEqual('&lt;&gt;&amp;"''', FStringWriter.ToString);
end;

procedure TXMLWriterTest.WhenWriteEscapedValuesMustWriteTheValueAsExpected;
begin
  FXMLWriter.WriteEscapedValue('Value',
    function (AChar: Char): String
    begin
      if AChar = 'e' then
        Result := 'EEE'
      else
        Result := AChar;
    end);

  Assert.AreEqual('ValuEEE', FStringWriter.ToString);
end;

{ TXMLSerializerWriterTest }

procedure TXMLSerializerWriterTest.Setup;
begin
  FStringWriter := TStringWriter.Create;
  FXMLSerializerWriter := TXMLSerializerWriter.Create;
  FXMLWriter := TXMLWriter.Create(FStringWriter);
end;

procedure TXMLSerializerWriterTest.TearDown;
begin
  FStringWriter.Free;

  FXMLSerializerWriter.Free;

  FXMLWriter.Free;
end;

procedure TXMLSerializerWriterTest.WhenSerializeAnObjectMustCreateTheDocumentElementWithTheNameOfTheClass;
begin
  var Empty := TEmptyDocument.Create;

  FXMLSerializerWriter.Serialize(FXMLWriter, Empty);

  Assert.AreEqual('<EmptyDocument></EmptyDocument>', FStringWriter.ToString);

  Empty.Free;
end;

procedure TXMLSerializerWriterTest.WhenSerializeAnObjectMustSerializeThePropertiesInTheObject;
begin
  var AnObject := TObjectWithMoreProperties.Create;
  AnObject.NodeFloat := 123;
  AnObject.NodeInteger := 789;
  AnObject.NodeString := 'abc';

  FXMLSerializerWriter.Serialize(FXMLWriter, AnObject);

  Assert.AreEqual('<ObjectWithMoreProperties><NodeFloat>123</NodeFloat><NodeInteger>789</NodeInteger><NodeString>abc</NodeString></ObjectWithMoreProperties>',
    FStringWriter.ToString);

  AnObject.Free;
end;

procedure TXMLSerializerWriterTest.WhenSerializeAnObjectWithTheNodeNameAttributeMustCreateTheNodeDocumentoWithTheNameInTheAttribute;
begin
  var Empty := TEmptyDocumentWithNodeNameAttribute.Create;

  FXMLSerializerWriter.Serialize(FXMLWriter, Empty);

  Assert.AreEqual('<MyDocument></MyDocument>', FStringWriter.ToString);

  Empty.Free;
end;

end.

