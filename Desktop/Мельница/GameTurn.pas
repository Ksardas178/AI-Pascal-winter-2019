unit GameTurn;

{-------------------------------}

interface

type
  Turn = record
  
  public
    currentID, nextID, takenID: Integer;
    
    {$region Constructors}
    
    constructor create(t: turn);
    begin
      currentID := t.currentID;
      nextID := t.nextID;
      takenID := t.takenID;
    end;
    
    constructor create(start, finish, got: Integer);
    begin
      currentID := start;
      nextID := finish;
      takenID := got;
    end;
    
    constructor create(finish: Integer);
    begin
      currentID := -1;
      nextID := finish;
      takenID := -1;
    end;
  
    {$endRegion Constructors}
  
  end;

{-------------------------------}

implementation

{---------------------------------}

begin
end. 