program ObjectToXML.Test.Project;

{$STRONGLINKTYPES ON}

uses
  Test.Insight.Framework in '..\Externals\TestInsightFramework\Test.Insight.Framework.pas',
  ObjectToXML.Test in 'ObjectToXML.Test.pas',
  ObjectToXML in '..\ObjectToXML.pas';

begin
  TTestInsightFramework.ExecuteTests;
end.
