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
  DEFFORMHEIGHT = 394;
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

      ConditionalArray : array [0..(CONDITIONALCOUNT)-1] of string = (
                                                '[a-z=+\-&*\\]?[a-z]:[a-z]',
                                                '\bswitch\b'
                                                );

      NumberConditionalOperators: integer = 0;
      ifNumber: integer;




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
    MessageBox(ClientHandle,PChar('������ ����������� �������� ����������� ��� �� Java �� ������� ������'),PChar(' About '),0);
  end;

procedure TMainForm.b_OpenFileClick(Sender: TObject);
  var openDialog : TOpenDialog;
      CodeFile : string;
  begin
    try
      openDialog := TOpenDialog.Create(self);
      openDialog.InitialDir := 'C://';
      openDialog.Options := [ofFileMustExist];
      openDialog.Filter :='C/C++ files only|*.c';
      openDialog.FilterIndex := 1;
      if openDialog.Execute then  CodeFile:=openDialog.FileName;
      openDialog.Free;

      Code.Lines.LoadFromFile(CodeFile);

      b_EnterText.Visible := False;
      b_EnterText.Enabled := False;
      b_OpenFile.Visible := False;
      b_OpenFile.Enabled := False;
      b_Analyze.Enabled := True;
      //ConditionalOperators.Caption := ''
      Code.Visible := True;
      MainForm.Height := DEFFORMHEIGHT;
    except
      ClearInformation;
      ShowMessage('������ � ������');
    end;

  end;

procedure TMainForm.b_EnterTextClick(Sender: TObject);
  begin
    b_EnterText.Visible := False;
    b_EnterText.Enabled := False;
    b_OpenFile.Visible := False;
    b_OpenFile.Enabled := False;
    b_Analyze.Enabled := True;
    //MaximalAttachments.Caption := '';
    Code.Text := '';
    Code.Visible := True;
    MainForm.Height := DEFFORMHEIGHT;
  end;

procedure TMainForm.FormCreate(Sender: TObject);
  begin
    MainForm.Height := MINFORMHEIGHT;
  end;

  //-----------------------------[Code analyze]-----------------------------------
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
      ShowMessage(CodeString);
      for CurrentOperator := 0 to (COMMENTSCOUNT - 1) do
      begin
        RegularExpression.Create(CommentsArray[CurrentOperator]);
        Matches := RegularExpression.Matches(CodeString);
        if (Matches.Count = 0) then
          ShowMessage('No comments')
        else
          ShowMessage('Comments count : ' + IntToStr(Matches.Count));
          for Count := 0 to (Matches.Count - 1) do
          begin
            //ShowMessage('Matches.Item[Count].Index : ' + inttostr(Matches.Item[Count].Index) + #13 + 'Matches.Item[Count].Length : ' + inttostr(Matches.Item[Count].Length) + #13 + 'Matches.Item[Count].Value : ' + Matches.Item[Count].Value);
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

  //------------------------------[ Main code ]-----------------------------------
procedure TMainForm.b_AnalyzeClick(Sender: TObject);
  var
    CodeString: String;
  begin
    if (Code.Text <> '') then
      Code.Lines.SaveToFile('backUpCode.txt');

    CodeString := Code.Text;
    CommentsRemove(CodeString);

    NumberConditionalOperators := 0;
    Code.Lines.Clear;
    Code.Lines.Insert(0,CodeString);

    //ShowMessage(CodeString);
  end;
end.
