%Vpq.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%
%funcion que calcula el voltaje para una barra pq
%

function [V] = Vpq(i, vbarra, Ybus)
    a = conj(vbarra(i).S)/conj(vbarra(i).Vp);
    b = -vbarra(i).Vp*Ybus(i,i); %Esto es para sumar todo directamente en la siguiente linea sin tener la necesidad de excluir el nodo en el que estoy trabajando (me evita colocar un condicional)
    for k = 1:size(Ybus,1)
      b = b + vbarra(k).Vp*Ybus(i,k);
    end
    V = (a - b)/Ybus(i,i);
end
