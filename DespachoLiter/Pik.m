%Pik.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%
%Con esta funcion se obtiene el flujo de potencia activa entre dos barras

function [P] = Pik(i,k, Ybus, vbarra)
    gik = real(-Ybus(i,k));
    bik = imag(-Ybus(i,k));
    angik= angle(vbarra(i).Vp)-angle(vbarra(k).Vp);
    a = gik*((abs(vbarra(i).Vp))^2);
    b = (abs(vbarra(i).Vp)*abs(vbarra(k).Vp));
    c = (gik*cos(angik))+(bik*sin(angik));
    P = a - (b*c);
end