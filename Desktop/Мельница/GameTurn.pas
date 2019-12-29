unit GameTurn;
{-------------------------------}
interface

type
  Turn = record
  
  public
    currentID, nextID, takenID: integer;
    
    constructor create(t: turn);
    begin
      currentID := t.currentID;
      nextID := t.nextID;
      takenID := t.takenID;
    end;
    
    constructor create(start, finish, got: integer);
    begin
      currentID := start;
      nextID := finish;
      takenID := got;
    end;
    
    constructor create(start, finish: integer);
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
end. 