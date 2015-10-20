// example.p
//&S-
//  print  hello  world
//&S+
begin
//&T-
	var a : integer;
//&T+
	var b : real;
	print "hello  world";
	a := 1+1;
	b := 1.23;
	if a > 01 then
		b := b*1.23e-1;
	end if
end
