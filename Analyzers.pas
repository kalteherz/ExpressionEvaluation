unit Analyzers;

interface

uses SyntaxLexicalAnalyzers;

type
  TSyntaxAnalyzer = SyntaxLexicalAnalyzers.TSyntaxAnalyzer;
  TLexicalAnalyzer = SyntaxLexicalAnalyzers.TLexicalAnalyzer;
  
  function GetDecimalSeparator: Char;
  
implementation

function GetDecimalSeparator: Char;
begin
  Result := SyntaxLexicalAnalyzers.GetDecimalSeparator;
end;

end.