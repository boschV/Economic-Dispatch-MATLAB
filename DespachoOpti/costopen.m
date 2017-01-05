%costopen.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169

%Este archivo contiene a la funcion de costo tomando en cuenta al factor de
%penalizaci�n

function f = costopen(x, gen)
    f = 0 ;
    for i = 1:size(gen,2)
        costo = gen(i).fpen*gen(i).costo;
        f = f + (polyval(costo, x(i)));
    end
end