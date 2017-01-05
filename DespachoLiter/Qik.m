%Qik.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%
%Con esta funcion se obtiene el flujo de potencia reactiva entre dos barras

function [Q] = Qik(i,k, BikShunt, Ybus, vbarra)
bik = imag(-Ybus(i,k));
gik = real(-Ybus(i,k));
biksh = BikShunt(i,k);
angik= angle(vbarra(i).Vp)-angle(vbarra(k).Vp);

a = (-(abs(vbarra(i).Vp))^2)*(bik+biksh);
b = (abs(vbarra(i).Vp)*abs(vbarra(k).Vp));
c = (bik*cos(angik))-(gik*sin(angik));

Q = a + (b*c);

end