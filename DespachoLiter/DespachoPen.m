%DespachoPen.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169 
%Este archivo calcula los factores de penalización para cada generador y
%luego realiza un despacho utilizando la función lambda iterativo para
%encontrar las nuevas potencias de los generadores

%Calculo de los factores de penalizacion
for i = 1:numgen
    num = 0;
    den = 0;
    for j = 1:N_barras
        if gen(i).barra ~= j
            Gik = real(Ybus(gen(i).barra,j));
            Bik = imag(Ybus(gen(i).barra,j));
            angik = angle(vbarra(gen(i).barra).Vp)-angle(vbarra(j).Vp);
            Vi = abs(vbarra(gen(i).barra).Vp);
            Vk = abs(vbarra(j).Vp);
            num = num + (Gik*Vk*sin(angik))*(-2*Vi);
            den = den + (Vi*Vk)*(-Gik*sin(angik)+Bik*cos(angik));
            
        end
        gen(i).fpen= (1-(num/den))^(-1);
    end 
end

%-------------------------Lambda iterativo---------------------------------

porcSalto= 0.5;

%Se calcula el valor inicial para el lambda iterativo (Se elige un promedio
%entre los valores de lambda de todos los generadores)

for i = 1:numgen
    gen(i).lambd = polyval(gen(i).CI, Sbase*vbarra(gen(i).barra).Pgen)*gen(i).fpen;
    lambini = lambini + (gen(i).lambd/numgen);
end

%Se realiza el despacho
DespEconPen = lambdaiter(gen, Pgentot,lambini,porcSalto);
