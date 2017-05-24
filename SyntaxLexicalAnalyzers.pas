unit SyntaxLexicalAnalyzers;

interface 
  
type

  TLexemeType = (ltEqual, ltLess, ltGreater, ltLessOrEqual, ltGreaterOrEqual, ltNotEqual,
                 ltPlus, ltMinus, ltOr, ltXor,
                 ltAsterisk, ltSlash, ltDiv, ltMod, ltAnd,
                 ltNot, ltBinNot,
                 ltCaret,
                 ltLeftBracket, ltRightBracket,
                 ltIdentifier,
                 ltNumber,
                 ltEnd);

  TLexeme = record
    LexemeType: TLexemeType;
    Pos: Integer;
    Lexeme: string;
  end;

  TSyntaxAnalyzer = record
    private
      Lexemes: Queue<TLexeme>;
      Indentifiers: SortedDictionary<String, Real>;
      function GetVarValue: Real;
      function Base: Real;
      function Factor: Real;
      function Term: Real;
      function MathExpr: Real;
      function Expr: Real;
    public
      function Calc(const InputString: String; const InputIndentifiers: SortedDictionary<String, Real>): Real;
  end;

  TLexicalAnalyzer = record
    private
      Lexemes: Queue<TLexeme>;
      Pos, StrLength: Integer;
      Str: String;
      procedure SkipeWhiteSpace;
      procedure ExtractLexeme;
      procedure PutLexeme(LexemeType: TLexemeType; Pos: Integer; const Lexeme: String);
      procedure ExtractNumber;
      procedure ExtractWord;
    public
      procedure ExtractLexemes(const InputString: String; OutLexemes: Queue<TLexeme>);
  end;

  function GetDecimalSeparator: Char;

implementation

var
  DecimalSeparator: Char := '.';


const
  Eps = 0.0000001;
  Alphabet = ['A'..'Z', 'a'..'z', 'А'..'Я', 'а'..'я', '_'];
  Digits = ['0'..'9'];
  Comparison = [ltEqual, ltLess, ltGreater, ltLessOrEqual, ltGreaterOrEqual, ltNotEqual];
  Operator1 = [ltPlus, ltMinus, ltOr, ltXor];
  Operator2 = [ltAsterisk, ltSlash, ltDiv, ltMod, ltAnd];

//Синтаксический анализатор
function TSyntaxAnalyzer.GetVarValue: Real;
var
  VarValue: Real;
begin
  if Indentifiers.TryGetValue(LowerCase(Lexemes.Peek.Lexeme), VarValue) then
    Result := VarValue
  else
    raise new Exception('Необъявленная переменная "' + Lexemes.Peek.Lexeme + '" в позиции ' + IntToStr(Lexemes.Peek.Pos));
end;

function TSyntaxAnalyzer.Base: Real;
begin
  case Lexemes.Peek.LexemeType of
    ltLeftBracket:
      begin
        Lexemes.Dequeue;
        Result := Expr;
        if Lexemes.Peek.LexemeType <> ltRightBracket then
          raise new Exception('Ожидается ")" в позиции ' + IntToStr(Lexemes.Peek.Pos));
        Lexemes.Dequeue;
      end;
    ltIdentifier:
      begin
        Result := GetVarValue;
        Lexemes.Dequeue;
      end;
    ltNumber:
      begin
        var StrNumber := Lexemes.Dequeue.Lexeme;
        if DecimalSeparator = '.' then
          StrNumber := StrNumber.Replace(',', '.')
        else
          StrNumber := StrNumber.Replace('.', ',');
        Result := StrToFloat(StrNumber);
      end;
    else
      raise new Exception('Некорректный символ в позиции ' + IntToStr(Lexemes.Peek.Pos));
  end;
end;

function TSyntaxAnalyzer.Factor: Real;
begin
  case Lexemes.Peek.LexemeType of
    ltPlus:
      begin
        Lexemes.Dequeue;
        Result := Factor;
      end;
    ltMinus:
      begin
        Lexemes.Dequeue;
        Result := -Factor;
      end;
    ltNot:
      begin
        Lexemes.Dequeue;
        Result := Byte(Trunc(Factor) = 0);
      end;
    ltBinNot:
      begin
        Lexemes.Dequeue;
        Result := not Trunc(Factor);
      end
    else
      begin
        Result := Base;
        if Lexemes.Peek.LexemeType = ltCaret then begin
          Lexemes.Dequeue;
          Result := Power(Result, Factor);
        end;
      end;
  end;
end;

function TSyntaxAnalyzer.Term: Real;
var
  Op: TLexemeType;
begin
  Result := Factor;
  while Lexemes.Peek.LexemeType in Operator2 do begin
    Op := Lexemes.Dequeue.LexemeType;
    case Op of
      ltAsterisk: Result := Result * Factor;
      ltSlash: Result := Result / Factor;
      ltDiv: Result := Trunc(Result) div Trunc(Factor);
      ltMod: Result := Trunc(Result) mod Trunc(Factor);
      ltAnd: Result := Trunc(Result) and Trunc(Factor);
    end;
  end;
end;

function TSyntaxAnalyzer.MathExpr: Real;
var
  Op: TLexemeType;
begin
  Result := Term;
  while Lexemes.Peek.LexemeType in Operator1 do begin
    Op := Lexemes.Dequeue.LexemeType;
    case Op of
      ltPlus: Result += Term;
      ltMinus: Result -= Term;
      ltOr: Result := Trunc(Result) or Trunc(Term);
      ltXor: Result := Trunc(Result) xor Trunc(Term);
    end;
  end;
end;

function TSyntaxAnalyzer.Expr: Real;
var
  Op: TLexemeType;
begin
  Result := MathExpr;
  while Lexemes.Peek.LexemeType in Comparison do begin
    Op := Lexemes.Dequeue.LexemeType;
    case Op of
        ltEqual: Result := Byte(Abs(Result - MathExpr) < Eps);
        ltLess: Result := Byte(Result < MathExpr);
        ltGreater: Result := Byte(Result > MathExpr);
        ltLessOrEqual: Result := Byte(Result <= MathExpr);
        ltGreaterOrEqual: Result := Byte(Result >= MathExpr);
        ltNotEqual: Result := Byte(Abs(Result - MathExpr) >= Eps);
    end;
  end;
end;

function TSyntaxAnalyzer.Calc(const InputString: String; const InputIndentifiers: SortedDictionary<String, Real>): Real;
var
  LexAn: TLexicalAnalyzer;
begin
  //Инициализация
  Indentifiers := InputIndentifiers;
  Lexemes := new Queue<TLexeme>;
  LexAn.ExtractLexemes(InputString, Lexemes);
  //Вычисление
  Result := Expr;
  if Lexemes.Peek.LexemeType <> ltEnd then
    raise new Exception('Недопустимая лексема в позиции ' + IntToStr(Lexemes.Peek.Pos));
end;

//Лексический анализатор
procedure TLexicalAnalyzer.ExtractLexemes(const InputString: String; OutLexemes: Queue<TLexeme>);
begin
  //Получаем разделитель целой и дробной части
  DecimalSeparator := GetDecimalSeparator;
  //Инициализация
  Lexemes := OutLexemes;
  Str := InputString;
  StrLength := Length(Str);
  Pos := 1;
  //Получаем лексемы
  while Pos <= StrLength do begin
    SkipeWhiteSpace;
    ExtractLexeme;
  end;
  PutLexeme(ltEnd, Pos, '');
end;

procedure TLexicalAnalyzer.SkipeWhiteSpace;
begin
  while (Pos <= StrLength) and (Str[Pos] in [' ', #10, #13, #9]) do
    Inc(Pos);
end;

procedure TLexicalAnalyzer.ExtractLexeme;
begin
  if Pos > StrLength then
    Exit;
  case Str[Pos] of
    '(':
      begin
        PutLexeme(ltLeftBracket, Pos, '');
        Inc(Pos);
      end;
    ')':
      begin
        PutLexeme(ltRightBracket, Pos, '');
        Inc(Pos);
      end;
    '*':
      begin
        PutLexeme(ltAsterisk, Pos, '');
        Inc(Pos);
       end;
    '+':
      begin
        PutLexeme(ltPlus, Pos, '');
        Inc(Pos);
      end;
    '-':
      begin
        PutLexeme(ltMinus, Pos, '');
        Inc(Pos);
      end;
    '/':
      begin
        PutLexeme(ltSlash, Pos, '');
        Inc(Pos);
      end;
    '<':
      if (Pos < StrLength) and (Str[Pos + 1] = '=') then begin
        PutLexeme(ltLessOrEqual, Pos, '');
        Inc(Pos, 2);
      end else if (Pos < StrLength) and (Str[Pos + 1] = '>') then begin
        PutLexeme(ltNotEqual, Pos, '');
        Inc(Pos, 2);
      end else begin
        PutLexeme(ltLess, Pos, '');
        Inc(Pos);
      end;
    '=':
      begin
        PutLexeme(ltEqual, Pos, '');
        Inc(Pos);
      end;
    '>':
      if (Pos < StrLength) and (Str[Pos + 1] = '=') then begin
        PutLexeme(ltGreaterOrEqual, Pos, '');
        Inc(Pos, 2);
      end else begin
        PutLexeme(ltGreater, Pos, '');
        Inc(Pos);
      end;
    '^':
      begin
        PutLexeme(ltCaret, Pos, '');
        Inc(Pos);
      end;
    else
      if Str[Pos] in Alphabet then
        ExtractWord
      else if Str[Pos] in Digits then
        ExtractNumber
      else
        raise new Exception('Некорректный символ в позиции ' + IntToStr(Pos));
  end;
end;

procedure TLexicalAnalyzer.ExtractNumber;
var
  FirstPos, ExpPos: Integer;
begin
  FirstPos := Pos;
  //Целая часть числа
  repeat
    Inc(Pos);
  until (Pos > StrLength) or not (Str[Pos] in Digits);
  //Дробная часть числа
  if (Pos <= StrLength) and ((Str[Pos] = '.') or (Str[Pos] = ',')) then begin
    Inc(Pos);
    if (Pos > StrLength) or not (Str[Pos] in Digits) then
      Dec(Pos)
    else
      repeat
        Inc(Pos);
      until (Pos > StrLength) or not (Str[Pos] in Digits);
  end;
  //Экспонента  
  if (Pos <= StrLength) and (UpCase(Str[Pos]) = 'E') then
  begin
    ExpPos := Pos;
    Inc(Pos);
    if Pos > StrLength then
      Pos := ExpPos
    else begin
      if Str[Pos] in ['+', '-'] then
        Inc(Pos);
      if (Pos > StrLength) or not (Str[Pos] in Digits) then
        Pos := ExpPos
      else
        repeat
          Inc(Pos);
        until (Pos > StrLength) or not (Str[Pos] in Digits);
    end;
  end;
  //Помещаем в лексемы
  PutLexeme(ltNumber, FirstPos, Copy(Str, FirstPos, Pos - FirstPos));
end;

procedure TLexicalAnalyzer.ExtractWord;
var
  FirstPos: Integer;
  NewWord, LCNewWord: String;
begin
  FirstPos := Pos;
  Inc(Pos);
  while (Pos <= StrLength) and ((Str[Pos] in Digits) or (Str[Pos] in Alphabet)) do
    Inc(Pos);
  NewWord := Copy(Str, FirstPos, Pos - FirstPos);
  LCNewWord := LowerCase(NewWord);
  if LCNewWord = 'or' then
    PutLexeme(ltOr, FirstPos, '')
  else if LCNewWord = 'xor' then
    PutLexeme(ltXor, FirstPos, '')
  else if LCNewWord = 'div' then
    PutLexeme(ltDiv, FirstPos, '')
  else if LCNewWord = 'mod' then
    PutLexeme(ltMod, FirstPos, '')
  else if LCNewWord = 'and' then
    PutLexeme(ltAnd, FirstPos, '')
  else if LCNewWord = 'not' then
    PutLexeme(ltNot, FirstPos, '')
  else if LCNewWord = 'binnot' then
    PutLexeme(ltBinNot, FirstPos, '')
  else
    PutLexeme(ltIdentifier, FirstPos, NewWord);
end;

procedure TLexicalAnalyzer.PutLexeme(LexemeType: TLexemeType; Pos: Integer; const Lexeme: string);
var
  NewLexeme: TLexeme;
begin
  NewLexeme.LexemeType := LexemeType;
  NewLexeme.Pos := Pos;
  NewLexeme.Lexeme := Lexeme;
  Lexemes.Enqueue(NewLexeme);
end;

function GetDecimalSeparator: Char;
begin
  Result := FloatToStr(1.1)[2]
end;


end.