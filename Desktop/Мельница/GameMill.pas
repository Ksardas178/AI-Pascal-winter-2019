unit GameMill;
{-------------------------------}
interface

uses GamePoint;

type
  Mill = class
    elements: list<integer>;//Индексы поля, составляющие мельницу
    
    constructor create(a, b, c: integer);
    begin
      elements:=new List<integer>;
      elements.Add(a);
      elements.Add(b);
      elements.Add(c);
    end;
    
    constructor create(s: string);
    begin
      elements:=new List<integer>;
      var idxs := s.Split(' ');
      for var i := 0 to 2 do
        elements.Add(idxs[i].ToInteger);
    end;
    
    public function hasElement(e: integer):boolean;
    begin
      result:=elements.Contains(e);
    end;
    
    
    
  end;
  
  MillArr = array of Mill;
{-------------------------------}
implementation

{---------------------------------}
begin
end . 