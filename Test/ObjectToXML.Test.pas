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
    [Test]
    procedure WhenWriteADoubleValueMustWriteTheValueAsExpected;
    [Test]
    procedure WhenWriteAnIntegerValueMustWriteTheValueAsExpected;
    [Test]
    procedure WhenWriteAnUnsigedIntegerValueMustWriteTheValueAsExpected;
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
    [Test]
    procedure WhenSerializeAnObjectWithAnEmptyValueMustWriteTheXMLAsExpected;
    [Test]
    procedure WhenSerializeAnObjectWithFloatNumberMustWritTheXMLWithLocalizedFormat;
    [Test]
    procedure WhenAnPropertyHasTheNumberFormatAttributeMustWriteTheXMLWithThisFormatAsExpected;
    [Test]
    procedure WHenTheObjectHasTheNumberSeparatorAttributeMustWriteTheFloatValuesAsExpected;
    [Test]
    procedure WHenTheObjectHasOnlyTheNumberSeparatorAttributeMustWriteTheFloatValuesAsExpected;
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

  TObjectEmptyNode = class
  private
    FEmptyNode: String;
  published
    property EmptyNode: String read FEmptyNode write FEmptyNode;
  end;

  TObjectFloatNode = class
  private
    FFloatNode: Double;
  published
    property FloatNode: Double read FFloatNode write FFloatNode;
  end;

  TObjectNumberFormat = class
  private
    FValue: Double;
  published
    [NumberFormat('000.000')]
    property Value: Double read FValue write FValue;
  end;

  [NumberSeparator('T', 'D')]
  TObjectNumberSeparator = class
  private
    FValue: Double;
  published
    [NumberFormat('#,##0.0')]
    property Value: Double read FValue write FValue;
  end;

  [NumberSeparator('T', 'D')]
  TObjectNumberSeparatorOnly = class
  private
    FValue: Double;
  published
    property Value: Double read FValue write FValue;
  end;

implementation

uses System.SysUtils;

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

procedure TXMLWriterTest.WhenWriteADoubleValueMustWriteTheValueAsExpected;
begin
  FXMLWriter.WriteValue(123.456);

  Assert.AreEqual(FloatToStr(123.456), FStringWriter.ToString);
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

procedure TXMLWriterTest.WhenWriteAnIntegerValueMustWriteTheValueAsExpected;
begin
  FXMLWriter.WriteValue(-123);

  Assert.AreEqual('-123', FStringWriter.ToString);
end;

procedure TXMLWriterTest.WhenWriteAnUnsigedIntegerValueMustWriteTheValueAsExpected;
begin
  var Value: UInt64 := 123;

  FXMLWriter.WriteValue(Value);

  Assert.AreEqual('123', FStringWriter.ToString);
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

procedure TXMLSerializerWriterTest.WhenAnPropertyHasTheNumberFormatAttributeMustWriteTheXMLWithThisFormatAsExpected;
begin
  var AnObject := TObjectNumberFormat.Create;
  AnObject.Value := 123.4;

  FXMLSerializerWriter.Serialize(FXMLWriter, AnObject);

  Assert.AreEqual(Format('<ObjectNumberFormat><Value>%s</Value></ObjectNumberFormat>', [FormatFloat('000.000', AnObject.Value)]), FStringWriter.ToString);

  AnObject.Free;
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

procedure TXMLSerializerWriterTest.WhenSerializeAnObjectWithAnEmptyValueMustWriteTheXMLAsExpected;
begin
  var AnObject := TObjectEmptyNode.Create;

  FXMLSerializerWriter.Serialize(FXMLWriter, AnObject);

  Assert.AreEqual('<ObjectEmptyNode><EmptyNode/></ObjectEmptyNode>', FStringWriter.ToString);

  AnObject.Free;
end;

procedure TXMLSerializerWriterTest.WhenSerializeAnObjectWithFloatNumberMustWritTheXMLWithLocalizedFormat;
begin
  var AnObject := TObjectFloatNode.Create;
  AnObject.FloatNode := 123.456;

  FXMLSerializerWriter.Serialize(FXMLWriter, AnObject);

  Assert.AreEqual(Format('<ObjectFloatNode><FloatNode>%s</FloatNode></ObjectFloatNode>', [FloatToStr(AnObject.FloatNode)]), FStringWriter.ToString);

  AnObject.Free;
end;

procedure TXMLSerializerWriterTest.WhenSerializeAnObjectWithTheNodeNameAttributeMustCreateTheNodeDocumentoWithTheNameInTheAttribute;
begin
  var Empty := TEmptyDocumentWithNodeNameAttribute.Create;

  FXMLSerializerWriter.Serialize(FXMLWriter, Empty);

  Assert.AreEqual('<MyDocument></MyDocument>', FStringWriter.ToString);

  Empty.Free;
end;

procedure TXMLSerializerWriterTest.WHenTheObjectHasOnlyTheNumberSeparatorAttributeMustWriteTheFloatValuesAsExpected;
begin
  var AnObject := TObjectNumberSeparatorOnly.Create;
  AnObject.Value := 123456.78901;
  var AFormat := TFormatSettings.Invariant;
  AFormat.DecimalSeparator := 'D';
  AFormat.ThousandSeparator := 'T';

  FXMLSerializerWriter.Serialize(FXMLWriter, AnObject);

  Assert.AreEqual(Format('<ObjectNumberSeparatorOnly><Value>%s</Value></ObjectNumberSeparatorOnly>', [FloatToStr(AnObject.Value, AFormat)]), FStringWriter.ToString);

  AnObject.Free;
end;

procedure TXMLSerializerWriterTest.WHenTheObjectHasTheNumberSeparatorAttributeMustWriteTheFloatValuesAsExpected;
begin
  var AnObject := TObjectNumberSeparator.Create;
  AnObject.Value := 123456.78901;
  var AFormat := TFormatSettings.Invariant;
  AFormat.DecimalSeparator := 'D';
  AFormat.ThousandSeparator := 'T';

  FXMLSerializerWriter.Serialize(FXMLWriter, AnObject);

  Assert.AreEqual(Format('<ObjectNumberSeparator><Value>%s</Value></ObjectNumberSeparator>', [FormatFloat('#,0.0', AnObject.Value, AFormat)]), FStringWriter.ToString);

  AnObject.Free;
end;

end.

