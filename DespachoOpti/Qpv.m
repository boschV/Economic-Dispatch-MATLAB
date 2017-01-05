%Qpv.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%
%funcion que calula la Q para una barra PV

function [Q] = Qpv(i, vbarra, Ybus)
    suma=0;
    for k = 1:size(Ybus,1)
        suma = suma + vbarra(k).Vp*Ybus(i,k);          
    end
    S = conj(vbarra(i).Vp)*suma;
    Q = -imag(S);
end
