unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls, RegularExpressions, StrUtils, Math;

type
  TMainForm = class(TForm)
    b_OpenFile: TButton;
    b_EnterText: TButton;
    Answers: TGroupBox;
    l_NumberOfOperators: TLabel;
    NumberOfOperators: TLabel;
    ConditionalOperators: TLabel;
    l_ConditionOperators: TLabel;
    l_MaximalAttachments: TLabel;
    MaximalAttachments: TLabel;
    l_RelativeComplexity: TLabel;
    RelativeComplexity: TLabel;
    b_Analyze: TButton;
    Code: TMemo;
    Menu: TMainMenu;
    b_File: TMenuItem;
    b_Clear: TMenuItem;
    b_Exit: TMenuItem;
    b_Help: TMenuItem;
    b_About: TMenuItem;
    procedure b_ClearClick(Sender: TObject);
    procedure b_ExitClick(Sender: TObject);
    procedure b_AboutClick(Sender: TObject);
    procedure b_OpenFileClick(Sender: TObject);
    procedure b_EnterTextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure b_AnalyzeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

const
  DEFFORMHEIGHT = 485;
  MINFORMHEIGHT = 200;
  OPERATORSCOUNT = 42;
  COMMENTSCOUNT = 3;
  CONDITIONALCOUNT = 2;
  ENDLINE = #13;
  NEWLINE = #10;
  TAB = #9;

var
    CommentsArray: array [0..(COMMENTSCOUNT)-1] of string = (
                                  '(([\/][\*]\W).+?[^\\]+?[^\\][\*][\/])|([\/][\*].+?[^\\]+?[^\\][\*][\/])' ,
                                  '[\/][\/].+[^\n]+?[^\n]' ,
                                  '["].*?[^\\].?["]'
                                  );

    OperatorsArray: array [0..(OPERATORSCOUNT - 1)] of string = ('\b=\b','\b\+\b',
          '\b-\b','\+\+','--','\b%\b','![a-z]','\b==\b','\b!=\b','\b>\b','\b<\b',
          '\b>=\b','\b<=\b','\b&&\b','\b||\b','\b&\b','\b|\b','\b^\b','\b<<\b',
          '\b>>\b','[[a-z]]','\bint\b','\bfloat\b','\bboolean\b','\bdouble\b',
          '\bbyte\b','\bdelete\b','\bnew\b',',','\bbreak\b', '\bpublic\b',
          '\bgoto\b','\bchar\b','{','\bSystem[\.]','\bimport\b',
          '-=','\+=','\bvoid\b','\bin[\. ]','\bpackage\b', '\bprivate\b');

    ConditionalArray : array [0..(CONDITIONALCOUNT)-1] of string = (
                                              '[a-z=+\-&*\\]?[a-z]:[a-z]',
                                              '\bswitch\b'
                                              );

    NumberOperators: integer = 0;
    NumberConditionalOperators: integer = 0;
    ifNumber: integer;



//--------------------[Form setup and correctly work]---------------------------
procedure ClearInformation;
begin
  with MainForm do
  begin
    Height := MINFORMHEIGHT;
    Code.Text := '';
    Code.Visible := False;
    b_EnterText.Visible := True;
    b_EnterText.Enabled := True;
    b_OpenFile.Visible := True;
    b_OpenFile.Enabled := True;
    b_Analyze.Enabled := False;
    ConditionalOperators.Caption := '';
    NumberOfOperators.Caption := '';
    RelativeComplexity.Caption := '';
    MaximalAttachments.Caption := '';
    Code.ReadOnly := False;
  end;
end;

procedure TMainForm.b_ExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.b_ClearClick(Sender: TObject);
begin
  ClearInformation;
end;

procedure TMainForm.b_AboutClick(Sender: TObject);
begin
  MessageBox(ClientHandle,PChar('Данное программное средство анализирует код на Java по метрике Джилба'),PChar(' About '),0);
end;

procedure TMainForm.b_OpenFileClick(Sender: TObject);
var openDialog : TOpenDialog;
    CodeFile : string;
begin
  try
    openDialog := TOpenDialog.Create(self);
    openDialog.InitialDir := 'C://';
    openDialog.Options := [ofFileMustExist];
    openDialog.Filter :='Text files only|*.txt';
    openDialog.FilterIndex := 1;
    if openDialog.Execute then  CodeFile:=openDialog.FileName;
    openDialog.Free;

    Code.Lines.LoadFromFile(CodeFile);

    b_EnterText.Visible := False;
    b_EnterText.Enabled := False;
    b_OpenFile.Visible := False;
    b_OpenFile.Enabled := False;
    b_Analyze.Enabled := True;
    ConditionalOperators.Caption := '';
    NumberOfOperators.Caption := '';
    RelativeComplexity.Caption := '';
    MaximalAttachments.Caption := '';
    Code.Visible := True;
    MainForm.Height := DEFFORMHEIGHT;
  except
    ClearInformation;
    ShowMessage('Ошибка в чтении');
  end;

end;

procedure TMainForm.b_EnterTextClick(Sender: TObject);
begin
  b_EnterText.Visible := False;
  b_EnterText.Enabled := False;
  b_OpenFile.Visible := False;
  b_OpenFile.Enabled := False;
  b_Analyze.Enabled := True;
  ConditionalOperators.Caption := '';
  NumberOfOperators.Caption := '';
  RelativeComplexity.Caption := '';
  MaximalAttachments.Caption := '';
  Code.Text := '';
  Code.Visible := True;
  MainForm.Height := DEFFORMHEIGHT;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MainForm.Height := MINFORMHEIGHT;
end;

//-----------------------------[Code analyze]-----------------------------------
procedure ClearEmpty (Code: TMemo);
var
  CountX, CountY: Integer;
begin
  for CountY := 0 to Code.Lines.Count-1 do
    for CountX := 1 to Code.Lines.Count - 2 do
      if (Code.Lines[CountX-1].IsEmpty  and Code.Lines[CountX].IsEmpty and Code.Lines[CountX+1].IsEmpty) then
      begin
        Code.Lines.Delete(CountX-1);
        Code.Lines.Delete(CountX-1);
      end;
end;

function CalculateNesting(Code: TMemo): Integer;
var
  RegularExpression: TRegEx;
  Matches: TMatchCollection;
  NestingArray: array of array of String;
  LastIndex, RowsCount, Nesting, maximalNesting: Integer;
  CheckIndex, LastClosedIf: Integer;
  LineIndex: Integer;
  checkClose: Integer;
  CheckException: Boolean;
begin
  checkClose := 0;
  ifNumber := 0;
  LastClosedIf := -1;
  LineIndex := 0;
  LastIndex := -1;
  CheckIndex := 0;
  RowsCount := 3;
  Nesting := 0;
  maximalNesting := 0;
  while LineIndex < Code.Lines.Capacity do
  begin
    RegularExpression.Create('\b\}|\}');
    Matches := RegularExpression.Matches(Code.Lines[LineIndex]);        //
    if (Matches.Count = 0) then
    begin
      RegularExpression.Create('\bif\b');
      Matches := RegularExpression.Matches(Code.Lines[LineIndex]);        //
      if (Matches.Count > 0) then
      begin
        inc(ifNumber);
        //ShowMessage('If number : ' + IntToStr(ifNumber));
        RegularExpression.Create('\bif?[^\}].+[\{]');
        Matches := RegularExpression.Matches(Code.Lines[LineIndex]);        //
        if (Matches.Count > 0) then
        begin
          //showmessage(Matches.Item[0].Value);
          inc(LastIndex);

          inc(Nesting);
          SetLength(NestingArray, LastIndex + 1, RowsCount);
          NestingArray[LastIndex, 0] := '-';
          NestingArray[LastIndex, 1] := '+';
          NestingArray[LastIndex, 2] := IntToStr(Nesting);
        end
        else
        begin
          inc(Nesting);
          if Nesting > maximalNesting then
            maximalNesting := Nesting;
          dec(Nesting);
        end;
      end
      else
      begin
        RegularExpression.Create('\belse?[^\}].+[\{]');
        Matches := RegularExpression.Matches(Code.Lines[LineIndex]);        //
        if (Matches.Count > 0) then
        begin
          inc(LastIndex);

          SetLength(NestingArray, LastIndex + 1, RowsCount);
          NestingArray[LastIndex, 0] := '-';
          NestingArray[LastIndex, 1] := '+';
          if (LastClosedIf > 0) then
          begin
            NestingArray[LastIndex, 2] := NestingArray[LastClosedIf, 2];
            Nesting := StrToInt(NestingArray[LastClosedIf, 2]);
          end
          else
            NestingArray[LastIndex, 2] := '0';
        end
        else
        begin
          RegularExpression.Create('\btry?[^\}].+[\{]|\bvoid?[^\}].+[\{]|\bpublic?[^\}].+[\{]|\bclass?[^\}].+[\{]|\bfor?[^\}].+[\{]|\bswitch?[^\}].+[\{]|\bwhile?[^\}].+[\{]');
          Matches := RegularExpression.Matches(Code.Lines[LineIndex]);        //
          if (Matches.Count > 0) then
          begin
            inc(LastIndex);

            SetLength(NestingArray, LastIndex + 1, RowsCount);
            NestingArray[LastIndex, 0] := '-';
            NestingArray[LastIndex, 1] := '-';
            NestingArray[LastIndex, 2] := IntToStr(Nesting);
          end;
        end;
      end;
    end
    else
    begin
      //showmessage(Matches.Item[0].Value);
      //SetLength(NestingArray, 0, RowsCount);
      inc(checkClose);
      CheckException := True;
      if checkClose < Length(NestingArray) then
        if ((LastIndex >= 0) and (Length(NestingArray) > 1)) then
        begin
          CheckIndex := LastIndex;
          while NestingArray[CheckIndex, 0] <> '-' do
          begin
            dec(CheckIndex);
            if CheckIndex < 0 then
              CheckException := False;
          end;
        end
        else
          CheckException := False
      else
        CheckException := False;

      if CheckException then
      begin
        NestingArray[CheckIndex, 0] := '+';
        if NestingArray[CheckIndex, 1] = '+' then
        begin
          LastClosedIf := CheckIndex;
          if maximalNesting < Nesting then
            maximalNesting := Nesting;
          dec(Nesting);
        end;
      end;
    end;
    inc(LineIndex);
  end;

  Result := maximalNesting;
end;

procedure CommentsRemove(var CodeString: String);
var
  RegularExpression: TRegEx;
  Matches: TMatchCollection;
  Match: TMatch;
  CurrentOperator: Integer;
  Count, Index: Integer;
  CommentsIndex: array of array of integer;
begin
  try
    CurrentOperator := 0;
    for CurrentOperator := 0 to (COMMENTSCOUNT - 1) do
    begin
      RegularExpression.Create(CommentsArray[CurrentOperator]);
      Matches := RegularExpression.Matches(CodeString);
      if (Matches.Count > 0) then
        for Count := 0 to (Matches.Count - 1) do
        begin
          SetLength(CommentsIndex, Count + 1, 2);
          CommentsIndex[Count, 0] := Matches.Item[Count].Index;
          CommentsIndex[Count, 1] := Matches.Item[Count].Length;
        end;

        for Count := (Matches.Count - 1) downto 0 do
          Delete(CodeString, CommentsIndex[Count,0], CommentsIndex[Count,1]);
    end;
  except
    ShowMessage('Attention !' + #13 + 'Programm error. Problem is in comments remove');
  end;
end;

function OperatorsFind(CodeString: String): Integer;
var
  RegularExpression: TRegEx;
  Matches: TMatchCollection;
  CurrentOperator: Integer;
begin
  try
    CurrentOperator := 0;
    for CurrentOperator := 0 to (OPERATORSCOUNT-1) do
    begin
      RegularExpression.Create(OperatorsArray[CurrentOperator]);
      Matches := RegularExpression.Matches(CodeString);
      NumberOperators := NumberOperators + Matches.Count;
      Result := NumberOperators;
    end;
  except
    ShowMessage('Attention !' + #13 + 'Program error. Problem is in operators searching.');
  end;
end;

function ConditionalOperatorsFind(CodeString: String): Integer;
var
  RegularExpression: TRegEx;
  Matches: TMatchCollection;
  CurrentOperator: Integer;
  Position, Length: Integer;
  Count: Integer;
begin
  try
    CurrentOperator := 0;
    for CurrentOperator := 0 to (CONDITIONALCOUNT-1) do
    begin
      RegularExpression.Create(ConditionalArray[CurrentOperator]);
      Matches := RegularExpression.Matches(CodeString);
      NumberConditionalOperators := NumberConditionalOperators + Matches.Count;
    end;
    Result := NumberConditionalOperators;
  except
    ShowMessage('Attention !' + #13 + 'Program error. Problem is in conditional operators search.');
    Result := 0;
  end;
end;

//------------------------------[ Main code ]-----------------------------------
procedure TMainForm.b_AnalyzeClick(Sender: TObject);
var
  CodeString: String;
begin
  if (Code.Text <> '') then
    Code.Lines.SaveToFile('backUpCode.txt');
  ClearEmpty(Code);

  CodeString := Code.Text;
  CommentsRemove(CodeString);

  NumberOperators := 0;
  NumberConditionalOperators := 0;

  MaximalAttachments.Caption := IntToStr(CalculateNesting(Code));
  NumberConditionalOperators := ConditionalOperatorsFind(CodeString) + ifNumber;
  NumberOfOperators.Caption := IntToStr(OperatorsFind(CodeString));
  ConditionalOperators.Caption := IntToStr(NumberConditionalOperators);
  if NumberOperators <> 0 then
    RelativeComplexity.Caption := FloatToStr(RoundTo((NumberConditionalOperators/
    (NumberOperators + NumberConditionalOperators)), -5))
  else
    RelativeComplexity.Caption := ' x / 0';

  Code.Lines.Clear;
  Code.Lines.Insert(0,CodeString);
  ClearEmpty(Code);

end;

end.
