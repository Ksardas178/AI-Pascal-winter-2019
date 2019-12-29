unit GameFieldInfo;

{-------------------------------}

interface

type
  FieldInfo = class
  
  private
    elements := new Integer[2];//Число фишек у команд
  
  public
    constructor create(blue, red: Integer);
    begin
      elements[0] := blue;
      elements[1] := red;
    end;
  
  public
    procedure remove(team: Integer);//Убирает фишку команды
    procedure add(team: Integer);//Добавляет фишку команде
    function getDifference(team, opponent: Integer): Integer;//Возвращает разницу между фишками команды и соперника
    function getElements(team: Integer): Integer;//Возвращает количество элементов команды
  
  end;

{-------------------------------}

implementation

//public
procedure FieldInfo.remove(team: Integer);//Убирает фишку команды
begin
  elements[team - 1] -= 1;
end;

//public
procedure FieldInfo.add(team: Integer);//Добавляет фишку команде
begin
  elements[team - 1] += 1;
end;

//public
function FieldInfo.getDifference(team, opponent: Integer): Integer;
begin
  result := elements[team - 1] - elements[opponent - 1];
end;

//public
function FieldInfo.getElements(team: Integer): Integer;//Возвращает количество элементов команды
begin
  result := elements[team - 1];
end;

{---------------------------------}

begin
end. 