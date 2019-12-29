unit GameFieldInfo;

{-------------------------------}

interface

type
  FieldInfo = class
  
  private
    elements := new integer[2];//Число фишек у команд
  
  public
    constructor create(blue, red: integer);
    begin
      elements[0] := blue;
      elements[1] := red;
    end;
  
  public
    procedure remove(team: integer);//Убирает фишку команды
    procedure add(team: integer);//Добавляет фишку команде
    function getDifference(team, opponent: integer): integer;//Возвращает разницу между фишками команды и соперника
    function getElements(team: integer): integer;//Возвращает количество элементов команды
  
  end;

{-------------------------------}

implementation

//public
procedure FieldInfo.remove(team: integer);//Убирает фишку команды
begin
  elements[team - 1] -= 1;
end;

//public
procedure FieldInfo.add(team: integer);//Добавляет фишку команде
begin
  elements[team - 1] += 1;
end;

//public
function FieldInfo.getDifference(team, opponent: integer): integer;
begin
  result := elements[team - 1] - elements[opponent - 1];
end;

//public
function FieldInfo.getElements(team: integer): integer;//Возвращает количество элементов команды
begin
  result := elements[team - 1];
end;

{---------------------------------}

begin
end. 