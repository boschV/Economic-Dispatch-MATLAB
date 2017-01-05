%costo.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169

%Este archivo contiene a la funcion de costo SIN tomar en cuenta al factor de
%penalización

function f = costo(x, gen)
    f = 0 ;
    for i = 1:size(gen,2)
        f = f + polyval(gen(i).costo,x(i));
    end
end