Unit GameFieldInfo;

{-------------------------------}
interface

type
  FieldInfo = class
    private elements: array [1..2] of byte;//Число фишек у команд
    
    public
    constructor create(blue, red: byte);
    begin
      elements[1] := blue;
      elements[2] := red;
    end;
    
    public procedure remove(team: byte);
    begin
      elements[team]-=1;
    end;
    
    public procedure add(team: byte);
    begin
      elements[team]+=1;
    end;
    
    public function getDifference(team, opponent:byte):shortint;
    begin
      result:=elements[team] - elements[opponent];
    end;
    
    public function getElements(team:byte):byte;
    begin
      result:=elements[team];
    end;
    
  end;

{-------------------------------}
implementation

{---------------------------------}
begin
end . 