uses BlockFileOfT;
 
type
  w = record
    s:array [0..2] of integer;
  end;
 
begin
  var f := new BlockFileOf<w>;
  f.Rewrite('состояния.bin');
  
  f.Size := 54; // размер можно задать сразу 
end.