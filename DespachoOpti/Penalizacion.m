%Penalizacion.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169 
%Este archivo calcula los factores de penalización para cada generador

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
