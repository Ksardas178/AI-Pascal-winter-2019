Unit GameFieldInfo;

{-------------------------------}
interface

type
  FieldInfo = class
    private elements: array [1..2] of integer;//Число фишек у команд
    
    public
    constructor create(blue, red: integer);
    begin
      elements[1] := blue;
      elements[2] := red;
    end;
    
    public procedure remove(team: integer);
    begin
      elements[team]-=1;
    end;
    
    public procedure add(team: integer);
    begin
      elements[team]+=1;
    end;
    
    public function getDifference(team, opponent:integer):integer;
    begin
      result:=elements[team] - elements[opponent];
    end;
    
    public function getElements(team:integer):integer;
    begin
      result:=elements[team];
    end;
    
  end;

{-------------------------------}
implementation

{---------------------------------}
begin
end . 