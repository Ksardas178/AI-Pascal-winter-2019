unit GameTurn;
{-------------------------------}
interface

type
  Turn = record
    currentID, nextID, takenID: shortint;
    
    constructor create(t:turn);
    begin
      currentID := t.currentID;
      nextID := t.nextID;
      takenID := t.takenID;
    end;
    
    constructor create(start, finish, got: shortint);
    begin
      currentID := start;
      nextID := finish;
      takenID := got;
    end;
    
    constructor create(start, finish: shortint);
    begin
      currentID := start;
      nextID := finish;
      takenID := -1;
    end;
  
  end;

{-------------------------------}
implementation
{---------------------------------}
begin

end . 