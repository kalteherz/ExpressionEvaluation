Unit MainFormUnit;

interface

uses System, System.Drawing, System.Windows.Forms, Analyzers, System.Data;

type
  MainForm = class(Form)
    procedure MainForm_Load(sender: Object; e: EventArgs);
    procedure button1_Click(sender: Object; e: EventArgs);
    procedure dataGridView1_DataError(sender: Object; e: DataGridViewDataErrorEventArgs);
  {$region FormDesigner}
  private
    {$resource MainFormUnit.MainForm.resources}
    dataGridView1: DataGridView;
    richTextBox1: RichTextBox;
    button1: Button;
    textBox1: TextBox;
    {$include MainFormUnit.MainForm.inc}
  {$endregion FormDesigner}
  public
    constructor;
    begin
      InitializeComponent;
    end;
  end;

implementation

var
  DecimalSeparator: Char := '.';
  Identifiers: DataTable;

procedure MainForm.MainForm_Load(sender: Object; e: EventArgs);
begin
  Left := Screen.PrimaryScreen.Bounds.Width div 2 - Width div 2;
  Top := Screen.PrimaryScreen.Bounds.Height div 2 - Height div 2;
  Identifiers := new DataTable;
  var ColumnName := Identifiers.Columns.Add('Имя переменной');
  var ColumnValue := Identifiers.Columns.Add('Значение');
  ColumnName.Unique := True;
  ColumnValue.DataType := System.Type.GetType('System.Double');
  Identifiers.Rows.Add('Перем', 8);
  dataGridView1.DataSource := Identifiers;
  DecimalSeparator := GetDecimalSeparator;
end;

procedure MainForm.button1_Click(sender: Object; e: EventArgs);
var
  SA: TSyntaxAnalyzer;
  Inds: SortedDictionary<String, Real>;
  DataColumn: System.Data.DataRow;
  R: Real;
begin
  try
    Inds := new SortedDictionary<String, Real>;
    foreach DataColumn in Identifiers.Rows do begin
      var StrNumber := DataColumn.ItemArray[1].ToString;
      if DecimalSeparator = '.' then
        StrNumber := StrNumber.Replace(',', '.')
      else
        StrNumber := StrNumber.Replace('.', ','); 
      if not TryStrToFloat(StrNumber, R) then 
        R := 0;
      Inds.Add(LowerCase(DataColumn.ItemArray[0].ToString), R);
    end;
    textBox1.Text := FloatToStr(SA.Calc(richTextBox1.Text, Inds));
  except
    on Err: Exception do
      textBox1.Text := Err.Message;
  end;
end;

procedure MainForm.dataGridView1_DataError(sender: Object; e: DataGridViewDataErrorEventArgs);
begin
  
end;

end.
