unit GameMill;

{-------------------------------}

interface

uses GamePoint;

type
  Mill = class
  
  public
    elements:= new Integer[3];//Индексы поля, составляющие мельницу
    
    {$region Constructors}
    
    constructor create(first, second, third: Integer);
    begin
      elements[0]:=first;
      elements[1]:=second;
      elements[2]:=third;
    end;
    
    constructor create(s: String);
    begin
      var idxs := s.Split(' ');
      for var i := 0 to 2 do
        elements[i]:=idxs[i].ToInteger;
    end;
  
    {$endRegion Constructors}
  
  public
    function hasElement(e: Integer): Boolean;//Проверяет наличие элемента в мельнице
  
  end;
  
  MillArr = array of Mill;

{-------------------------------}

implementation

//public 
function Mill.hasElement(e: Integer): Boolean;//Проверяет наличие элемента в мельнице
begin
  result := elements.Contains(e);
end;

{---------------------------------}

begin
end. 